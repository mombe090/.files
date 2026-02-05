#!/usr/bin/env bash
# Display installation summary

SUMMARY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$SUMMARY_DIR/.." && pwd)"

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

cat <<EOF

╔═══════════════════════════════════════════════════════════╗
║         Omarchy Dotfiles Patches - Summary                ║
╚═══════════════════════════════════════════════════════════╝

📁 Configurations Patched:
   ✓ Hyprland (custom configs in ~/.config/hypr/custom/)
   ✓ Zsh (custom configs in ~/.config/zsh/custom/)
   ✓ Git (custom config included)

📝 Files:
   • Log: $DOTFILES_LOG_FILE
   • Backups: $BACKUP_DIR

🔄 Next Steps:
   1. Restart your shell: exec zsh
   2. Reload Hyprland: hyprctl reload
   3. Verify configs work as expected

📚 Documentation:
   • Plan: $DOTFILES_ROOT/agents/plan/omarchy/
   • Scripts: $DOTFILES_ROOT/scripts/omarchy/

💡 Tips:
   • Run again anytime - it's idempotent!
   • Edit configs in $DOTFILES_ROOT and re-run to update
   • Use --dry-run to preview changes

EOF
