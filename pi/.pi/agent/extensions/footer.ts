import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import * as fs from "node:fs";
import * as path from "node:path";

const THINKING_ICON: Record<string, string> = {
  off: "○",
  minimal: "◎",
  low: "◉",
  medium: "●",
  high: "◆",
  xhigh: "◆◆",
};

const THINKING_COLOR: Record<string, string> = {
  off: "thinkingOff",
  minimal: "thinkingMinimal",
  low: "thinkingLow",
  medium: "thinkingMedium",
  high: "thinkingHigh",
  xhigh: "thinkingXhigh",
};

function fmtTokens(n: number): string {
  return n < 1000 ? `${n}` : `${(n / 1000).toFixed(1)}k`;
}

/**
 * Resolve cwd relative to the git root so the path shown is just the
 * sub-path inside the repo, e.g.  craftarc/iac/terraform
 * Falls back to the last 2 path segments when git root cannot be found.
 */
function cwdLabel(): string {
  const cwd = process.cwd();

  // Walk up looking for .git
  let dir = cwd;
  while (true) {
    if (fs.existsSync(path.join(dir, ".git"))) {
      const repoName = path.basename(dir);
      const rel      = path.relative(dir, cwd);
      return rel ? `${repoName}/${rel}` : repoName;
    }
    const parent = path.dirname(dir);
    if (parent === dir) break; // reached filesystem root
    dir = parent;
  }

  // No git root — show last 2 segments
  const parts = cwd.split(path.sep).filter(Boolean);
  return parts.slice(-2).join("/") || cwd;
}

function shortenModel(id: string): string {
  return id
    .replace(/^claude-/, "")   // "claude-sonnet-4-5" → "sonnet-4-5"
    .replace(/-\d{8}$/, "")    // strip date suffix e.g. "-20241022"
    .slice(0, 22);
}

export default function (pi: ExtensionAPI) {
  let requestRender: (() => void) | undefined;

  // Keep footer in sync when thinking level changes
  pi.on("thinking_level_select", async () => {
    requestRender?.();
  });

  pi.on("session_start", async (_event, ctx) => {
    ctx.ui.setFooter((tui, theme, footerData) => {
      requestRender = () => tui.requestRender();
      const unsub = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose() {
          unsub();
          requestRender = undefined;
        },
        invalidate() {},

        render(width: number): string[] {
          const dim = (s: string) => theme.fg("dim", s);
          const sep = dim(" · ");

          // ── Folder · branch / worktree ──────────────────────────────
          const branch  = footerData.getGitBranch();
          const folder  = cwdLabel();
          const branchSeg = branch
            ? `${dim(folder)}${dim(" ⎇ ")}${theme.fg("accent", branch)}`
            : `${dim(folder)}${dim(" ⎇  no-git")}`;

          // ── Tokens & cost ──────────────────────────────────────────────
          let input = 0, output = 0, cost = 0;
          for (const e of ctx.sessionManager.getBranch()) {
            if (e.type === "message" && e.message.role === "assistant") {
              const m = e.message as AssistantMessage;
              input  += m.usage.input;
              output += m.usage.output;
              cost   += m.usage.cost.total;
            }
          }
          const tokenSeg = theme.fg("muted", `↑${fmtTokens(input)} ↓${fmtTokens(output)}`);
          const costSeg  = theme.fg("muted", `$${cost.toFixed(3)}`);

          // ── Context window usage ───────────────────────────────────────
          const ctxUsage = ctx.getContextUsage();
          const ctxPct   = ctxUsage ? Math.round(ctxUsage.fraction * 100) : null;
          const ctxColor =
            ctxPct === null   ? "muted"   :
            ctxPct > 90       ? "error"   :
            ctxPct > 75       ? "warning" : "muted";
          const ctxSeg = ctxPct !== null
            ? `${sep}${theme.fg(ctxColor, `ctx ${ctxPct}%`)}`
            : "";

          // ── Model & thinking ───────────────────────────────────────────
          const modelId   = ctx.model?.id ?? "no-model";
          const level     = pi.getThinkingLevel();
          const icon      = THINKING_ICON[level]  ?? "○";
          const tColor    = THINKING_COLOR[level] ?? "dim";
          const modelSeg  = theme.fg("accent", shortenModel(modelId));
          const thinkSeg  = theme.fg(tColor, `${icon} ${level}`);

          // ── Assemble left & right blocks ───────────────────────────────
          const left  = ` ${branchSeg}${sep}${tokenSeg}${sep}${costSeg}${ctxSeg} `;
          const right = ` ${modelSeg}${sep}${thinkSeg} `;

          const gap = Math.max(1, width - visibleWidth(left) - visibleWidth(right));
          return [truncateToWidth(left + " ".repeat(gap) + right, width)];
        },
      };
    });
  });
}
