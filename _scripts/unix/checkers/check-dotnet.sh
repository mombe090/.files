#!/usr/bin/env bash
# Diagnostic script to check .NET installation and PATH issues

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== .NET Installation Diagnostics ===${NC}"
echo ""

# Check current PATH
echo -e "${YELLOW}Current PATH:${NC}"
echo "$PATH" | tr ':' '\n' | nl
echo ""

# Check if dotnet is in PATH
echo -e "${YELLOW}Checking 'dotnet' command:${NC}"
if command -v dotnet &> /dev/null; then
    echo -e "${GREEN}✓ dotnet found in PATH${NC}"
    echo "Location: $(which dotnet)"
    echo "Version: $(dotnet --version)"
else
    echo -e "${RED}✗ dotnet not found in PATH${NC}"
fi
echo ""

# Search for dotnet binary in common locations
echo -e "${YELLOW}Searching for dotnet binary:${NC}"
dotnet_paths=(
    "/usr/local/bin/dotnet"
    "/usr/local/share/dotnet/dotnet"
    "/usr/bin/dotnet"
    "/usr/share/dotnet/dotnet"
    "/opt/homebrew/bin/dotnet"
    "$HOME/.dotnet/dotnet"
)

found_any=false
for path in "${dotnet_paths[@]}"; do
    if [[ -f "$path" ]]; then
        echo -e "${GREEN}✓ Found: $path${NC}"
        if [[ -x "$path" ]]; then
            version=$("$path" --version 2>/dev/null || echo "unable to get version")
            echo "  Version: $version"
        else
            echo -e "  ${RED}Not executable${NC}"
        fi
        found_any=true
    fi
done

if [[ "$found_any" == "false" ]]; then
    echo -e "${RED}✗ No dotnet binary found in common locations${NC}"
fi
echo ""

# Check installed packages (OS-specific)
echo -e "${YELLOW}Checking installed .NET packages:${NC}"

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if command -v brew &> /dev/null; then
        echo "Homebrew casks:"
        brew list --cask | grep dotnet || echo "No dotnet casks found"
    fi
elif command -v apt &> /dev/null; then
    # Debian/Ubuntu
    echo "APT packages:"
    dpkg -l | grep dotnet || echo "No dotnet packages found"
elif command -v yum &> /dev/null; then
    # RHEL/Fedora
    echo "YUM/DNF packages:"
    rpm -qa | grep dotnet || echo "No dotnet packages found"
elif command -v pacman &> /dev/null; then
    # Arch
    echo "Pacman packages:"
    pacman -Q | grep dotnet || echo "No dotnet packages found"
fi
echo ""

# Check shell profile files
echo -e "${YELLOW}Checking shell profile files for dotnet PATH:${NC}"
profile_files=(
    "$HOME/.zshrc"
    "$HOME/.bashrc"
    "$HOME/.profile"
    "$HOME/.bash_profile"
)

for file in "${profile_files[@]}"; do
    if [[ -f "$file" ]]; then
        if grep -q "dotnet" "$file" 2>/dev/null; then
            echo -e "${GREEN}✓ $file contains 'dotnet'${NC}"
            grep --color=never "dotnet" "$file"
        fi
    fi
done
echo ""

# Recommendations
echo -e "${BLUE}=== Recommendations ===${NC}"
echo ""

if command -v dotnet &> /dev/null; then
    echo -e "${GREEN}✓ .NET is working correctly!${NC}"
else
    echo -e "${RED}✗ .NET needs configuration${NC}"
    echo ""
    echo "Try these steps:"
    echo ""
    echo "1. Restart your shell:"
    echo "   exec \$SHELL -l"
    echo ""
    
    # Find dotnet and suggest PATH fix
    for path in "${dotnet_paths[@]}"; do
        if [[ -f "$path" ]]; then
            dotnet_dir=$(dirname "$path")
            echo "2. Add dotnet to PATH (found at: $path):"
            if [[ -f "$HOME/.zshrc" ]]; then
                echo "   echo 'export PATH=\"\$PATH:$dotnet_dir\"' >> ~/.zshrc"
                echo "   source ~/.zshrc"
            elif [[ -f "$HOME/.bashrc" ]]; then
                echo "   echo 'export PATH=\"\$PATH:$dotnet_dir\"' >> ~/.bashrc"
                echo "   source ~/.bashrc"
            fi
            echo ""
            break
        fi
    done
    
    echo "3. If dotnet is not installed, run:"
    echo "   ./scripts/install-dotnet.sh"
    echo ""
fi
