#!/usr/bin/env python3
import subprocess
import sys
import os

def run(cmd, **kwargs):
    return subprocess.run(cmd, capture_output=True, text=True, **kwargs)

def get_unstaged_files():
    result = run(["git", "diff", "--name-only", "--diff-filter=M"])
    if result.returncode != 0:
        print("ERROR: not in a git repo.", file=sys.stderr)
        sys.exit(1)
    return [f.strip() for f in result.stdout.splitlines() if f.strip()]

def is_binary(filepath):
    result = run(["git", "diff", "--numstat", "--", filepath])
    if result.stdout.strip().startswith("-"):
        return True
    try:
        with open(filepath, "rb") as f:
            return b"\x00" in f.read(8000)
    except OSError:
        return True

def diff_is_eol_only(filepath):
    result = run(["git", "diff", "--ignore-cr-at-eol", "--", filepath])
    return result.stdout.strip() == ""

def get_committed_eol(filepath):
    result = run(["git", "show", f"HEAD:{filepath}"])
    if result.returncode != 0:
        result = run(["git", "show", f":{filepath}"])
    if result.returncode != 0:
        return "lf"
    content = result.stdout.encode("utf-8", errors="replace")
    return "crlf" if b"\r\n" in content else "lf"

def restore_eol(filepath, target_eol):
    with open(filepath, "rb") as f:
        original = f.read()
    normalized = original.replace(b"\r\n", b"\n").replace(b"\r", b"\n")
    converted = normalized.replace(b"\n", b"\r\n") if target_eol == "crlf" else normalized
    if converted == original:
        return False
    with open(filepath, "wb") as f:
        f.write(converted)
    return True

def main():
    unstaged = get_unstaged_files()
    if not unstaged:
        print("No unstaged modified files.")
        sys.exit(0)

    fixed = []
    skipped_real_changes = []
    skipped_binary = []

    for filepath in unstaged:
        if is_binary(filepath):
            skipped_binary.append(filepath)
            continue
        if not diff_is_eol_only(filepath):
            skipped_real_changes.append(filepath)
            continue
        target_eol = get_committed_eol(filepath)
        if restore_eol(filepath, target_eol):
            fixed.append((filepath, target_eol))

    if fixed:
        print(f"Fixed ({len(fixed)} files):")
        for f, eol in fixed:
            print(f"  ✓ {f}  →  {eol.upper()}")
    else:
        print("Nothing to fix — no EOL-only drifts found.")

    if skipped_real_changes:
        print(f"\nSkipped — real changes (not EOL-only) ({len(skipped_real_changes)}):")
        for f in skipped_real_changes:
            print(f"  ⚠ {f}")

    if skipped_binary:
        print(f"\nSkipped binary ({len(skipped_binary)}):")
        for f in skipped_binary:
            print(f"  ~ {f}")

if __name__ == "__main__":
    main()
