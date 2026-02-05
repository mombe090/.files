# =============================================================================
# Justfile - Dotfiles management
# =============================================================================

import '.just/_helpers.just'
import '.just/install.just'
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
    @echo -e "  {{color_green}}just install_minimal{{color_reset}}     Core tools only"
    @echo -e "  {{color_green}}just stow [PKG]{{color_reset}}          Stow a package (or all)"
    @echo -e "  {{color_green}}just update{{color_reset}}              git pull + mise upgrade + restow"
    @echo -e "  {{color_green}}just doctor{{color_reset}}              Check system health"
    @echo -e "  {{color_green}}just verify{{color_reset}}              Verify installations"
    @echo -e "  {{color_green}}just mise_upgrade{{color_reset}}        Upgrade mise tools"
    @echo ""
    @echo -e "  {{color_bold}}Run 'just --list' for all commands{{color_reset}}"
    @echo ""
