# =============================================================================
# Justfile - Main entry point for dotfiles management
# =============================================================================
# Modern command runner for managing dotfiles across Linux, macOS, and Windows
#
# Quick Start:
#   just --list           # Show all available commands
#   just help             # Show detailed help
#   just install_full     # Full installation
#   just doctor           # Check system health
#
# For more information, see: specs/just-integration/README.md
# =============================================================================

# Import all modules
import '.just/_helpers.just'
import '.just/install.just'
import '.just/stow.just'
import '.just/mise.just'
import '.just/verify.just'
import '.just/maintenance.just'
import '.just/windows.just'
import '.just/dev.just'

# Default recipe - show all available commands
default:
    @just --list --unsorted

# Show detailed help
help:
    @echo "╔══════════════════════════════════════════════════════════════╗"
    @echo "║           Dotfiles Management with Just                     ║"
    @echo "╚══════════════════════════════════════════════════════════════╝"
    @echo ""
    @echo "Common Commands:"
    @echo ""
    @echo "  📦 Installation:"
    @echo "     just install_full           Full installation (all tools)"
    @echo "     just install_minimal        Minimal installation (core only)"
    @echo "     just install_component NAME Install specific component"
    @echo ""
    @echo "  🔗 Stow (Symlinks):"
    @echo "     just stow [PACKAGE]         Stow package(s)"
    @echo "     just unstow [PACKAGE]       Remove symlinks"
    @echo "     just restow [PACKAGE]       Update symlinks"
    @echo ""
    @echo "  🔧 Tool Management:"
    @echo "     just mise_install           Install mise tools"
    @echo "     just mise_upgrade           Upgrade all tools"
    @echo "     just mise_list              List installed tools"
    @echo ""
    @echo "  ✅ Verification:"
    @echo "     just doctor                 Comprehensive health check"
    @echo "     just verify                 Verify all installations"
    @echo ""
    @echo "  🔄 Maintenance:"
    @echo "     just update                 Update everything"
    @echo "     just sync                   Quick sync (git pull + restow)"
    @echo "     just backup_create          Create backup"
    @echo "     just clean                  Clean temporary files"
    @echo ""
    @echo "  🪟 Windows-Specific:"
    @echo "     just win_install_packages   Install Windows packages"
    @echo "     just win_stow PACKAGE       Stow on Windows"
    @echo ""
    @echo "  🧪 Development:"
    @echo "     just test                   Run all tests"
    @echo "     just lint                   Lint shell scripts"
    @echo ""
    @echo "For full list: just --list"
    @echo "For specific help: just --show RECIPE_NAME"
    @echo ""
    @echo "Documentation: cat README.md"
    @echo "Specification: cat specs/just-integration/2026-02-04/specification.md"
    @echo ""

# Bootstrap: Install just itself (for new systems)
bootstrap:
    @echo "🚀 Bootstrapping dotfiles..."
    @{{just_scripts}}/bootstrap.sh
