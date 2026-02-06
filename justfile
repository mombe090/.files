# =============================================================================
# Justfile - Dotfiles management
# =============================================================================

import '.just/_helpers.just'
import '.just/install.just'
import '.just/packages.just'
import '.just/stow.just'
import '.just/mise.just'
import '.just/verify.just'
import '.just/maintenance.just'
import '.just/windows.just'
import '.just/dev.just'

# Show available commands
default:
    @echo ""
    @echo -e "{{color_bold}}Dotfiles{{color_reset}}"
    @echo ""
    @echo -e "  {{color_green}}just install_full{{color_reset}}        Install everything"
    @echo -e "  {{color_green}}just install_pro{{color_reset}}         Install professional packages (work-safe)"
    @echo -e "  {{color_green}}just install_perso{{color_reset}}       Install personal packages (includes pro)"
    @echo -e "  {{color_green}}just install_minimal{{color_reset}}     Core tools only"
    @echo -e "  {{color_green}}just packages_minimal{{color_reset}}    Install essential packages"
    @echo -e "  {{color_green}}just packages_info{{color_reset}}       Package system info"
    @echo -e "  {{color_green}}just stow [PKG]{{color_reset}}          Stow a package (or all)"
    @echo -e "  {{color_green}}just update{{color_reset}}              git pull + mise upgrade + restow"
    @echo -e "  {{color_green}}just doctor{{color_reset}}              Check system health"
    @echo -e "  {{color_green}}just verify{{color_reset}}              Verify installations"
    @echo ""
    @echo -e "  {{color_bold}}Run 'just --list' for all commands{{color_reset}}"
    @echo ""
