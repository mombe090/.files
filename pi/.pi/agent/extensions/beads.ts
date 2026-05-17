/**
 * Beads (bd) integration for pi coding agent.
 *
 * Replicates what `bd setup claude` does via hooks:
 *   - session_start   → runs `bd prime`, stores context
 *   - before_agent_start → injects context into system prompt once per session
 *   - footer status   → live issue counts via JSONL parse (no bd binary required)
 *   - /bd command     → run any bd subcommand inline
 *   - pre-compaction  → reminder to push beads to Dolt remote
 *
 * Requires: bd CLI in PATH (`npm install -g @beads/bd`)
 */

import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';
import { spawnSync } from 'node:child_process';
import * as fs from 'node:fs';
import * as path from 'node:path';

// ── helpers ──────────────────────────────────────────────────────────────────

function runBd(
  args: string[],
  cwd = process.cwd(),
): { stdout: string; stderr: string; ok: boolean } {
  const r = spawnSync('bd', args, { cwd, encoding: 'utf8', timeout: 15_000 });
  const ok = !r.error && r.status === 0;
  return { stdout: (r.stdout ?? '').trim(), stderr: (r.stderr ?? '').trim(), ok };
}

function bdAvailable(): boolean {
  const r = spawnSync('which', ['bd'], { encoding: 'utf8', timeout: 3000 });
  return r.status === 0;
}

/** Resolve the nearest .beads directory walking up from cwd. */
function beadsDir(cwd = process.cwd()): string | null {
  let dir = cwd;
  while (true) {
    const candidate = path.join(dir, '.beads');
    if (fs.existsSync(candidate)) return candidate;
    const parent = path.dirname(dir);
    if (parent === dir) return null;
    dir = parent;
  }
}

interface BeadsIssue {
  _type: string;
  id: string;
  title: string;
  status: string;
  priority: number;
  issue_type: string;
  dependency_count?: number;
}

function readIssuesFromJsonl(beadsPath: string): BeadsIssue[] {
  const file = path.join(beadsPath, 'issues.jsonl');
  if (!fs.existsSync(file)) return [];
  try {
    return fs
      .readFileSync(file, 'utf8')
      .split('\n')
      .filter(Boolean)
      .map((l) => JSON.parse(l) as BeadsIssue)
      .filter((i) => i._type === 'issue');
  } catch {
    return [];
  }
}

function countReady(issues: BeadsIssue[]): number {
  return issues.filter(
    (i) => i.status === 'open' && (i.dependency_count ?? 0) === 0,
  ).length;
}

function countInProgress(issues: BeadsIssue[]): number {
  return issues.filter((i) => i.status === 'in_progress').length;
}

// ── extension ─────────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  let primeContext: string | null = null;
  let injected = false;

  // ── session_start ──────────────────────────────────────────────────────────
  pi.on('session_start', async (_event, ctx) => {
    injected = false;
    primeContext = null;

    const bd = beadsDir();
    if (!bd) {
      // No .beads in this project tree — silent
      ctx.ui.setStatus('beads', undefined);
      return;
    }

    // Footer: issue counts direct from JSONL (fast, no binary needed)
    refreshStatus(ctx, bd);

    if (!bdAvailable()) {
      ctx.ui.setStatus(
        'beads',
        ctx.ui.theme.fg('warning', 'bd: not in PATH — install: npm i -g @beads/bd'),
      );
      return;
    }

    // Fetch prime context in background (non-blocking)
    const r = runBd(['prime']);
    if (r.ok && r.stdout) {
      primeContext = r.stdout;
    }
  });

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  function refreshStatus(ctx: any, bd: string) {
    const issues = readIssuesFromJsonl(bd);
    const ready = countReady(issues);
    const wip   = countInProgress(issues);

    const parts: string[] = [];
    if (ready > 0)  parts.push(ctx.ui.theme.fg('accent', `${ready} ready`));
    if (wip > 0)    parts.push(ctx.ui.theme.fg('muted', `${wip} wip`));

    const label = parts.length > 0
      ? `bd: ${parts.join(' · ')}`
      : ctx.ui.theme.fg('dim', 'bd: ✓');

    ctx.ui.setStatus('beads', label);
  }

  // ── before_agent_start: inject bd prime once per session ──────────────────
  pi.on('before_agent_start', async (event, _ctx) => {
    if (injected || !primeContext) return;
    injected = true;

    // Append beads context to the chained system prompt for this session
    return {
      systemPrompt: `${event.systemPrompt}\n\n---\n\n${primeContext}`,
    };
  });

  // ── pre-compaction: remind about bd dolt push ─────────────────────────────
  pi.on('session_before_compact', async (_event, ctx) => {
    const bd = beadsDir();
    if (!bd || !bdAvailable()) return;
    ctx.ui.notify(
      'Beads: remember to run `bd dolt push` to sync your issues to the remote.',
      'info',
    );
  });

  // ── /bd command ────────────────────────────────────────────────────────────
  pi.registerCommand('bd', {
    description: 'Beads issue tracker. Usage: /bd [subcommand ...args]  — e.g. /bd ready, /bd show <id>',
    handler: async (args, ctx) => {
      const bd = beadsDir();
      if (!bd) {
        ctx.ui.notify('No .beads directory found in this project tree.', 'error');
        return;
      }

      if (!bdAvailable()) {
        ctx.ui.notify(
          'bd not in PATH. Install: npm install -g @beads/bd',
          'error',
        );
        return;
      }

      const parts = (args ?? '').trim().split(/\s+/).filter(Boolean);

      // /bd  with no args → show prime
      if (parts.length === 0) {
        const r = runBd(['prime']);
        const out = r.ok ? r.stdout : `bd prime failed:\n${r.stderr}`;
        ctx.ui.notify(out.slice(0, 1500) + (out.length > 1500 ? '\n…(truncated)' : ''), r.ok ? 'info' : 'error');

        // Refresh footer
        refreshStatus(ctx, bd);
        return;
      }

      const r = runBd(parts);
      const out = (r.stdout + (r.stderr ? `\n${r.stderr}` : '')).trim() || '(no output)';
      ctx.ui.notify(
        out.slice(0, 1500) + (out.length > 1500 ? '\n…(truncated)' : ''),
        r.ok ? 'info' : 'error',
      );

      // Refresh footer after any mutating command
      const mutating = ['create', 'update', 'close', 'dep', 'claim'];
      if (mutating.includes(parts[0] ?? '')) {
        refreshStatus(ctx, bd);
      }
    },
  });

  // ── /bd-ready shortcut ────────────────────────────────────────────────────
  pi.registerCommand('bd-ready', {
    description: 'Show beads issues ready to work (no blockers)',
    handler: async (_args, ctx) => {
      const bd = beadsDir();
      if (!bd || !bdAvailable()) {
        ctx.ui.notify('bd not available.', 'error');
        return;
      }
      const r = runBd(['ready']);
      ctx.ui.notify(
        r.ok ? (r.stdout || '✨ No open issues ready.') : `Error: ${r.stderr}`,
        r.ok ? 'info' : 'error',
      );
    },
  });
}
