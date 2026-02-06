# Modern Fonts Installation Guide

## Overview

The `install-modern-fonts.sh` script installs three popular Nerd Fonts optimized for development:

1. **CascadiaMono Nerd Font** - Microsoft's Cascadia Code with Nerd Font icons
2. **JetBrainsMono Nerd Font** - JetBrains Mono with Nerd Font icons
3. **VictorMono Font** - Victor Mono with cursive italics

## Features

- ✅ Automatic OS detection (macOS/Linux)
- ✅ Downloads from official sources
- ✅ Installs to correct font directory
- ✅ Updates font cache (Linux)
- ✅ Lists currently installed fonts
- ✅ No admin/sudo required

## Usage

### Install All Fonts

```bash
./scripts/install-modern-fonts.sh
```

### List Installed Fonts

```bash
./scripts/install-modern-fonts.sh --list
```

### Show Help

```bash
./scripts/install-modern-fonts.sh --help
```

## Font Details

### CascadiaMono Nerd Font
- **Source**: [ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts)
- **Version**: v3.4.0
- **Features**:
  - Programming ligatures
  - Powerline glyphs
  - Font Awesome, Devicons, Octicons
  - Best for: Terminal, VSCode, Neovim

### JetBrainsMono Nerd Font
- **Source**: [ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts)
- **Version**: v3.4.0
- **Features**:
  - Increased height for better readability
  - Programming ligatures
  - All Nerd Font icons
  - Best for: IDEs, terminals, code editors

### VictorMono Font
- **Source**: [rubjo/victor-mono](https://github.com/rubjo/victor-mono)
- **Features**:
  - Cursive italics
  - Programming ligatures
  - Semi-connected cursive
  - Best for: Code with emphasis on italics/comments

## Installation Locations

### macOS
```
~/Library/Fonts/
```

### Linux
```
~/.local/share/fonts/
```

## Prerequisites

The script requires:
- `curl` or `wget` (for downloading)
- `unzip` (for extracting fonts)

### Install Prerequisites

**macOS:**
```bash
brew install wget unzip
```

**Ubuntu/Debian:**
```bash
sudo apt install wget unzip
```

**RHEL/Fedora:**
```bash
sudo yum install wget unzip
```

## Post-Installation

### 1. Restart Terminal/IDE
Close and reopen your terminal or IDE for fonts to be available.

### 2. Configure Terminal

**Alacritty** (`~/.config/alacritty/alacritty.toml`):
```toml
[font]
normal = { family = "CaskaydiaMono Nerd Font Mono", style = "Regular" }
size = 13.0
```

**Ghostty** (`~/.config/ghostty/config`):
```
font-family = "CaskaydiaMono Nerd Font Mono"
font-size = 13
```

**VSCode** (`settings.json`):
```json
{
  "editor.fontFamily": "'JetBrainsMono Nerd Font Mono', monospace",
  "editor.fontLigatures": true,
  "editor.fontSize": 13
}
```

**Neovim** (if using GUI):
```lua
vim.opt.guifont = "JetBrainsMono Nerd Font Mono:h13"
```

### 3. Enable Ligatures

Most terminals and editors support ligatures for better code rendering:
- **Alacritty**: Enabled by default
- **Ghostty**: Enabled by default
- **VSCode**: Set `"editor.fontLigatures": true`

### 4. Verify Icons Display

Test icon rendering:
```bash
echo "    "
```

You should see various icons (folder, git, check, info, star).

## Troubleshooting

### Fonts Not Showing Up

**macOS:**
- Fonts are immediately available after installation
- If not, open Font Book and verify fonts are listed

**Linux:**
- Run: `fc-cache -f -v`
- Verify: `fc-list | grep -i "cascadia\|jetbrains\|victor"`
- Restart X11/Wayland session if needed

### Download Failures

If downloads fail:
```bash
# Check internet connection
ping github.com

# Try manual download:
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaMono.zip -o ~/Downloads/CascadiaMono.zip
```

### Permission Issues

The script installs to user directories (no sudo required). If you get permission errors:
```bash
# macOS
chmod 755 ~/Library/Fonts

# Linux
chmod 755 ~/.local/share/fonts
```

## Font Variants

Each font family includes multiple variants:

### Weight Variants
- Light
- Regular
- Medium
- SemiBold
- Bold

### Style Variants
- Regular (upright)
- Italic
- Bold
- Bold Italic

### Terminal Usage
For terminals, use the **Mono** variant:
- ✅ `CaskaydiaMono Nerd Font Mono`
- ✅ `JetBrainsMono Nerd Font Mono`
- ❌ `CaskaydiaMono Nerd Font` (proportional, for text editors)

## Included Icons

Nerd Fonts include thousands of icons from:
- Font Awesome
- Devicons
- Octicons
- Powerline Extra Symbols
- Material Design Icons
- Weather Icons
- And many more...

## Performance

Font installation typically takes:
- **Download**: 5-30 seconds per font (depends on connection)
- **Extraction**: 1-5 seconds per font
- **Installation**: Instant (just file copy)
- **Total**: ~1-2 minutes for all 3 fonts

## Uninstallation

To remove fonts:

**macOS:**
```bash
# List fonts
ls ~/Library/Fonts/ | grep -i "cascadia\|jetbrains\|victor"

# Remove specific font
rm ~/Library/Fonts/CaskaydiaMono*
```

**Linux:**
```bash
# List fonts
ls ~/.local/share/fonts/ | grep -i "cascadia\|jetbrains\|victor"

# Remove specific font
rm ~/.local/share/fonts/CaskaydiaMono*

# Update cache
fc-cache -f
```

## Integration with Dotfiles

Add to your installation workflow:

**`install.sh`:**
```bash
# Optional: Install modern fonts
if command -v unzip &> /dev/null; then
    ./scripts/install-modern-fonts.sh
fi
```

Or install manually after setup:
```bash
cd ~/.files
./scripts/install-modern-fonts.sh
```

## Resources

- [Nerd Fonts Website](https://www.nerdfonts.com/)
- [Cascadia Code](https://github.com/microsoft/cascadia-code)
- [JetBrains Mono](https://www.jetbrains.com/lp/mono/)
- [Victor Mono](https://rubjo.github.io/victor-mono/)
- [Programming Fonts](https://www.programmingfonts.org/) - Test drive fonts

## Examples

### CascadiaMono Features
```javascript
// Ligatures in action:
!== !== >= <= => -> :: == === != !== ++ -- && ||
```

### VictorMono Cursive
Italics and comments appear in beautiful cursive:
```python
# This comment is in cursive
def example():  # Cursive italic style
    return True
```

### JetBrainsMono Clarity
Optimized for reading code with increased height:
```rust
fn main() {
    let result = calculate();
    println!("{}", result);
}
```

## FAQ

**Q: Do I need all three fonts?**
A: No, install only the ones you want. Each can be installed independently.

**Q: Will this slow down my terminal?**
A: No, font rendering is handled by your terminal emulator efficiently.

**Q: Can I use these in VS Code?**
A: Yes! All three fonts work perfectly in VS Code with ligatures.

**Q: Are these free?**
A: Yes, all fonts are free and open source (SIL Open Font License).

**Q: Do these work in tmux/zellij?**
A: Yes, terminal multiplexers use your terminal's font settings.

**Q: What's the difference between "Mono" and non-"Mono"?**
A: "Mono" variants have fixed width (monospace) - required for terminals. Non-Mono variants are proportional - for text editors/IDEs.
