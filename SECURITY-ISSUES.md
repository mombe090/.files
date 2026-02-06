# Security Issues Backlog

This document contains the security issues identified in the security audit. Each issue is ready to be created as a GitHub issue.

---

## P0 - Critical Priority (Fix Immediately)

### Issue #1: Add checksum verification for external script downloads

**Labels:** `security`, `P0-critical`, `installation`

**Description:**

Currently, the installation scripts download and execute code without verification:

```bash
# _scripts/unix/installers/install-mise.sh (lines 25, 30, 35)
curl https://mise.run | sh
curl https://mise.run | sudo MISE_INSTALL_PATH=/usr/local/bin/mise sh

# _scripts/just/install-just.sh (lines 130, 135)
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash
```

**Security Risk:**

If the upstream source (mise.run or just.systems) is compromised, malicious code could be executed with user or sudo privileges.

**Affected Files:**
- `_scripts/unix/installers/install-mise.sh`
- `_scripts/just/install-just.sh`

**Recommendation:**

1. Download installer to temporary file first
2. Verify SHA256 checksum against known good value
3. Execute only if checksum matches
4. Provide manual installation documentation as alternative

**Example Implementation:**

```bash
install_mise_verified() {
    local installer_url="https://mise.run/install.sh"
    local temp_file="/tmp/mise-install-$$.sh"
    local expected_sha256="KNOWN_SHA256_HERE"  # Get from official source
    
    # Download installer
    log_info "Downloading mise installer..."
    curl -fsSL "$installer_url" -o "$temp_file"
    
    # Verify checksum (if known)
    if [[ -n "$expected_sha256" ]]; then
        log_info "Verifying checksum..."
        echo "$expected_sha256  $temp_file" | sha256sum -c || {
            log_error "Checksum verification failed!"
            rm -f "$temp_file"
            exit 1
        }
    else
        log_warn "No checksum available, proceeding with caution..."
        # Display script content and ask for confirmation
        cat "$temp_file"
        confirm_prompt "Review the script above. Continue?" || exit 0
    fi
    
    # Execute installer
    bash "$temp_file"
    rm -f "$temp_file"
}
```

**Alternative Approach:**

For tools that don't provide checksums:
1. Download binary from GitHub releases (with checksums)
2. Use package managers where available (apt, brew)
3. Build from source with commit hash verification

**Acceptance Criteria:**
- [ ] All external script downloads verify checksums
- [ ] Fallback to manual review if checksums unavailable
- [ ] Documentation updated with manual installation steps
- [ ] Scripts fail safely if verification fails

---

### Issue #2: Implement work/personal profile separation

**Labels:** `security`, `P0-critical`, `configuration`, `multi-machine`

**Description:**

Currently, all machines (work laptops, personal computers, WSL) share the same configurations without separation. This creates several security risks:

1. **Configuration Leakage:** Personal tools/aliases could be exposed in corporate environment
2. **Accidental Commits:** Work-specific configs might be committed to public repository
3. **No Trust Boundaries:** Same secrets/env vars loaded on all machines

**Affected Files:**
- All files in `zsh/.config/zsh/`
- `bash/.bashrc`
- `git/.gitconfig.template`
- Environment variable configurations

**Recommendation:**

Create a profile-based system that separates configurations by context (work/personal) or by specific machine (hostname).

**Proposed Structure:**

```
zsh/.config/zsh/
├── aliases.zsh          # Common aliases (safe for all machines)
├── env.zsh              # Common environment variables
├── history.zsh          # History configuration
├── profiles/
│   ├── README.md        # Documentation
│   ├── example.zsh      # Template for machine-specific configs
│   ├── work.zsh         # Work-specific configs (not committed)
│   ├── personal.zsh     # Personal-specific configs (not committed)
│   └── ${HOSTNAME}.zsh  # Machine-specific configs (not committed)
```

**Implementation:**

```zsh
# zsh/.config/zsh/env.zsh (end of file)
# Load profile-specific configuration
PROFILE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/profiles"

# Try loading in order of specificity:
# 1. Hostname-specific profile
# 2. Environment-specific profile (DOTFILES_PROFILE env var)
# 3. Default profile

if [[ -f "$PROFILE_DIR/${HOSTNAME}.zsh" ]]; then
    source "$PROFILE_DIR/${HOSTNAME}.zsh"
elif [[ -n "$DOTFILES_PROFILE" ]] && [[ -f "$PROFILE_DIR/${DOTFILES_PROFILE}.zsh" ]]; then
    source "$PROFILE_DIR/${DOTFILES_PROFILE}.zsh"
elif [[ -f "$PROFILE_DIR/default.zsh" ]]; then
    source "$PROFILE_DIR/default.zsh"
fi
```

```gitignore
# .gitignore (add)
# Machine-specific profiles (never commit)
zsh/.config/zsh/profiles/*
!zsh/.config/zsh/profiles/README.md
!zsh/.config/zsh/profiles/example.zsh
```

**Profile Examples:**

```zsh
# zsh/.config/zsh/profiles/work.zsh (example - not committed)
# Work-specific environment variables
export COMPANY_VPN="enabled"
export CORPORATE_PROXY="http://proxy.company.com:8080"

# Work-safe aliases only
unalias personal-tool 2>/dev/null  # Remove personal aliases if any

# Restricted history (more aggressive filtering)
export HISTIGNORE="*password*:*token*:*secret*:*key*:*api*:*bearer*:export *"

# Disable Copilot for work
export COPILOT_ENABLED=false
```

```zsh
# zsh/.config/zsh/profiles/personal.zsh (example - not committed)
# Personal environment variables
export PERSONAL_PROJECT_PATH="$HOME/projects"

# Personal aliases
alias home-server='ssh user@homeserver.local'
alias personal-git='git config user.email "personal@email.com"'
```

**Setup Script:**

```bash
# _scripts/unix/tools/setup-profile.sh
setup_profile() {
    local profile_name="$1"
    local profile_dir="$HOME/.config/zsh/profiles"
    
    mkdir -p "$profile_dir"
    
    if [[ -f "$profile_dir/example.zsh" ]]; then
        cp "$profile_dir/example.zsh" "$profile_dir/${profile_name}.zsh"
        log_success "Created profile: $profile_dir/${profile_name}.zsh"
        log_info "Edit this file to customize for this machine"
    else
        log_error "Example profile not found"
    fi
}

# Interactive setup
log_info "Select profile type:"
echo "  1) work"
echo "  2) personal"
echo "  3) ${HOSTNAME} (machine-specific)"
read -p "Choice: " choice

case $choice in
    1) setup_profile "work" ;;
    2) setup_profile "personal" ;;
    3) setup_profile "${HOSTNAME}" ;;
    *) log_error "Invalid choice" ;;
esac
```

**Alternative Approach:**

For more advanced separation, consider using environment variable to specify profile:

```bash
# In ~/.zshenv (before dotfiles load)
export DOTFILES_PROFILE="work"  # or "personal"
```

**Acceptance Criteria:**
- [ ] Profile directory structure created
- [ ] Profile loading logic implemented
- [ ] Example profiles documented
- [ ] .gitignore updated to exclude profiles
- [ ] Setup script created for easy profile creation
- [ ] README.md with usage instructions
- [ ] Migration guide for existing configs

---

### Issue #3: Add guards to prevent dangerous rm -rf operations

**Labels:** `security`, `P0-critical`, `safety`, `scripts`

**Description:**

Several scripts use `rm -rf` with variables that could be dangerous if unset or incorrectly set:

```bash
# _scripts/unix/tools/backup.sh:38
rm -rf "$BACKUP_DIR" 2>/dev/null || true

# _scripts/unix/tools/manage-stow.sh (multiple locations)
rm -rf "$target"
rm -rf "$config_zsh"

# _scripts/omarchy/helpers/backup.sh
rm -rf "$target"
```

**Security Risk:**

If variables like `$BACKUP_DIR` or `$target` are:
- Unset (empty)
- Set to `/` or `$HOME`
- Containing shell expansions
- Controlled by user input

The command could delete critical system files or user data.

**Affected Files:**
- `_scripts/unix/tools/backup.sh`
- `_scripts/unix/tools/manage-stow.sh`
- `_scripts/unix/tools/uninstall.sh`
- `_scripts/omarchy/helpers/backup.sh`
- `_scripts/unix/installers/install-lazyvim.sh`
- `_scripts/unix/installers/install-modern-fonts.sh`
- `_scripts/unix/installers/install-nushell.sh`
- `_scripts/just/install-just.sh`

**Recommendation:**

Add comprehensive safety checks before any `rm -rf` operation:

**1. Create a safe deletion library function:**

```bash
# _scripts/unix/lib/safe-delete.sh

# Safe recursive deletion with multiple guards
safe_rm_rf() {
    local target="$1"
    local expected_pattern="$2"  # Optional: regex pattern target should match
    
    # Guard 1: Variable must not be empty
    if [[ -z "$target" ]]; then
        log_error "safe_rm_rf: target path is empty, aborting"
        return 1
    fi
    
    # Guard 2: Must not be root or home
    if [[ "$target" == "/" ]] || [[ "$target" == "$HOME" ]] || [[ "$target" == "$HOME/" ]]; then
        log_error "safe_rm_rf: refusing to delete critical directory: $target"
        return 1
    fi
    
    # Guard 3: Must be an absolute path or start with ./
    if [[ ! "$target" =~ ^/ ]] && [[ ! "$target" =~ ^\./ ]]; then
        log_error "safe_rm_rf: target must be absolute or relative path: $target"
        return 1
    fi
    
    # Guard 4: Path must exist
    if [[ ! -e "$target" ]]; then
        log_warn "safe_rm_rf: path does not exist (already deleted?): $target"
        return 0
    fi
    
    # Guard 5: Optional pattern matching
    if [[ -n "$expected_pattern" ]]; then
        if [[ ! "$target" =~ $expected_pattern ]]; then
            log_error "safe_rm_rf: target doesn't match expected pattern"
            log_error "  Target: $target"
            log_error "  Expected: $expected_pattern"
            return 1
        fi
    fi
    
    # Guard 6: For backup directories, extra verification
    if [[ "$target" =~ backup ]]; then
        log_info "Deleting backup directory: $target"
    elif [[ "$target" =~ /tmp/ ]]; then
        log_info "Deleting temporary directory: $target"
    else
        log_warn "About to delete: $target"
        confirm_prompt "Are you sure you want to delete this?" || return 1
    fi
    
    # Finally, execute deletion
    rm -rf "$target"
    log_success "Deleted: $target"
}

# Export function
export -f safe_rm_rf
```

**2. Update scripts to use safe_rm_rf:**

```bash
# Before (unsafe):
rm -rf "$BACKUP_DIR" 2>/dev/null || true

# After (safe):
source "$DOTFILES_ROOT/_scripts/unix/lib/safe-delete.sh"
safe_rm_rf "$BACKUP_DIR" ".*backup.*" || {
    log_error "Failed to delete backup directory"
    exit 1
}
```

**3. Additional specific guards:**

```bash
# _scripts/unix/tools/backup.sh
# Before deletion, verify BACKUP_DIR is set and looks reasonable
if [[ -z "$BACKUP_DIR" ]]; then
    log_error "BACKUP_DIR is not set"
    exit 1
fi

if [[ ! "$BACKUP_DIR" =~ \.backup$ ]] && [[ ! "$BACKUP_DIR" =~ backup/ ]]; then
    log_error "BACKUP_DIR doesn't look like a backup directory: $BACKUP_DIR"
    log_error "Expected path to contain 'backup' or end with '.backup'"
    exit 1
fi

safe_rm_rf "$BACKUP_DIR"
```

**4. Audit all rm -rf usage:**

Create a script to find and verify all usages:

```bash
# _scripts/unix/tools/audit-rm-usage.sh
#!/usr/bin/env bash

echo "Auditing all rm -rf usage in scripts..."
echo ""

grep -rn "rm -rf" _scripts --include="*.sh" | while IFS=: read -r file line content; do
    echo "File: $file:$line"
    echo "  $content"
    echo "  ⚠️  Verify this deletion is safe"
    echo ""
done
```

**Acceptance Criteria:**
- [ ] `safe_rm_rf` function created in lib/safe-delete.sh
- [ ] All critical rm -rf operations use safe_rm_rf
- [ ] Variable validation before all deletions
- [ ] Pattern matching for expected paths
- [ ] Confirmation prompts for non-obvious deletions
- [ ] Audit script to find unsafe rm usage
- [ ] Documentation of safe deletion practices
- [ ] Tests for safe_rm_rf function

---

## P1 - High Priority (Fix Soon)

### Issue #4: Add command history security filtering

**Labels:** `security`, `P1-high`, `shell`, `privacy`

**Description:**

Shell history currently stores all commands without filtering, including those that may contain:
- Passwords (`mysql -p password123`)
- API tokens (`export API_TOKEN=abc123`)
- AWS credentials (`aws configure set aws_secret_access_key ...`)
- Bearer tokens (`curl -H "Authorization: Bearer token"`)

**Affected Files:**
- `zsh/.config/zsh/history.zsh`
- `bash/.bashrc`

**Current Configuration:**

```zsh
# zsh/.config/zsh/history.zsh
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
```

**Recommendation:**

Add history filtering and security options:

```zsh
# zsh/.config/zsh/history.zsh

# History size
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE

# Security options
setopt HIST_IGNORE_SPACE      # Don't save commands that start with space
setopt HIST_NO_STORE          # Don't store history commands in history
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks
setopt INC_APPEND_HISTORY     # Append immediately, not on shell exit
setopt HIST_VERIFY            # Show command before executing from history

# Pattern-based filtering (zsh 5.8+)
# Commands matching these patterns won't be saved
HISTORY_IGNORE="(ls|cd|pwd|exit|clear|history|cat .env*|*password*|*token*|*secret*|*key*|export *API*|export *TOKEN*|export *SECRET*|export *PASSWORD*|*bearer*|*auth*key*|aws*secret*|gcloud*key*)"
```

```bash
# bash/.bashrc

# History control
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignorespace:ignoredups:erasedups

# Don't save these patterns to history
HISTIGNORE="ls:cd:pwd:exit:clear:history:cat .env*:*password*:*token*:*secret*:*key*:export *API*:export *TOKEN*:*bearer*"

# Append to history, don't overwrite
shopt -s histappend
```

**Additional Security Measures:**

1. **Educate users to prefix sensitive commands with space:**

```bash
# Regular command (saved to history)
export PATH=$PATH:/new/path

# Sensitive command (NOT saved - note the leading space)
 export API_TOKEN=secret123
```

2. **Create helper function to clear specific history:**

```zsh
# zsh/.config/zsh/functions/clear-history-pattern.zsh

clear_history_pattern() {
    local pattern="$1"
    
    if [[ -z "$pattern" ]]; then
        echo "Usage: clear_history_pattern <pattern>"
        echo "Example: clear_history_pattern 'password123'"
        return 1
    fi
    
    # Backup history
    cp "$HISTFILE" "${HISTFILE}.backup.$(date +%Y%m%d-%H%M%S)"
    
    # Remove lines matching pattern
    grep -v "$pattern" "$HISTFILE" > "${HISTFILE}.tmp"
    mv "${HISTFILE}.tmp" "$HISTFILE"
    
    # Reload history
    fc -R
    
    echo "✓ Removed history entries matching: $pattern"
    echo "  Backup saved to: ${HISTFILE}.backup.*"
}
```

3. **Create secure command wrapper:**

```zsh
# zsh/.config/zsh/functions/secure-cmd.zsh

# Run command without saving to history
secure() {
    local HISTFILE=/dev/null
    "$@"
}

# Usage:
# secure mysql -u root -p secretpassword
# secure export API_KEY=abc123
```

4. **Add history audit script:**

```bash
# _scripts/unix/tools/audit-history.sh

#!/usr/bin/env bash
# Audit shell history for sensitive patterns

HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
PATTERNS=(
    "password"
    "token"
    "secret"
    "api.key"
    "bearer"
    "credential"
    "private.key"
)

echo "Auditing history for sensitive patterns..."
echo "History file: $HISTFILE"
echo ""

for pattern in "${PATTERNS[@]}"; do
    matches=$(grep -i "$pattern" "$HISTFILE" 2>/dev/null | wc -l)
    if [[ $matches -gt 0 ]]; then
        echo "⚠️  Found $matches entries matching: $pattern"
    fi
done

echo ""
echo "To view matches: grep -i 'pattern' $HISTFILE"
echo "To clear matches: clear_history_pattern 'pattern'"
```

**Documentation:**

Create user guide in `_docs/HISTORY_SECURITY.md`:

```markdown
# Shell History Security Guide

## Protecting Sensitive Commands

### Method 1: Prefix with Space
Commands starting with a space are not saved to history:
\`\`\`bash
 export API_TOKEN=secret123  # Note the leading space
\`\`\`

### Method 2: Use secure() wrapper
\`\`\`bash
secure export API_TOKEN=secret123
secure mysql -u root -p secretpassword
\`\`\`

### Method 3: Temporarily disable history
\`\`\`bash
set +o history  # Disable
export API_TOKEN=secret123
set -o history  # Re-enable
\`\`\`

## Audit Your History
\`\`\`bash
bash _scripts/unix/tools/audit-history.sh
\`\`\`

## Clear Leaked Secrets
\`\`\`bash
clear_history_pattern 'password123'
\`\`\`
```

**Acceptance Criteria:**
- [ ] HIST_IGNORE_SPACE enabled in zsh and bash
- [ ] HISTORY_IGNORE patterns configured
- [ ] Helper functions created (clear_history_pattern, secure)
- [ ] History audit script created
- [ ] Documentation added
- [ ] User guide with examples
- [ ] .zsh_history and .bash_history added to .gitignore (if not already)

---

### Issue #5: Review and restrict Copilot file access

**Labels:** `security`, `P1-high`, `ai`, `data-privacy`

**Description:**

GitHub Copilot sends code to external servers for AI processing. Currently configured for multiple file types without restrictions:

```lua
# nvim/.config/nvim/lua/plugins/copilot.lua
filetypes = {
  markdown = true,
  help = true,
  terraform = true,  # ⚠️ May contain infrastructure secrets
  java = true,
}
```

**Security Concerns:**

1. **Terraform Files:** May contain:
   - Infrastructure credentials
   - API endpoints
   - Database connection strings
   - Cloud provider secrets

2. **Markdown Files:** May contain:
   - Documentation with example secrets
   - Personal notes with sensitive information
   - Meeting notes with confidential data

3. **No File-level Restrictions:** All files of enabled types are sent to Copilot

**Recommendation:**

**1. Restrict Copilot by file type:**

```lua
# nvim/.config/nvim/lua/plugins/copilot.lua
return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "BufReadPost",
  opts = {
    suggestion = {
      enabled = not vim.g.ai_cmp,
      auto_trigger = true,
      hide_during_completion = vim.g.ai_cmp,
      keymap = {
        accept = false,
        next = "<M-]>",
        prev = "<M-[>",
      },
    },
    panel = { enabled = false },
    filetypes = {
      -- Safe for AI assistance
      markdown = true,
      help = true,
      java = true,
      python = true,
      javascript = true,
      typescript = true,
      
      -- Disable for sensitive file types
      terraform = false,      # Infrastructure as Code
      yaml = false,           # Often contains secrets
      toml = false,           # Config files
      json = false,           # May contain credentials
      sh = false,             # Shell scripts with env vars
      zsh = false,
      bash = false,
      
      -- Explicitly disable
      [".env"] = false,
      [".env.*"] = false,
      ["*secret*"] = false,
      ["*credential*"] = false,
      ["*password*"] = false,
      gitconfig = false,
      ssh_config = false,
      
      -- Disable by default
      ["*"] = false,
    },
  },
}
```

**2. Add path-based restrictions:**

```lua
# nvim/.config/nvim/lua/plugins/copilot-paths.lua

local M = {}

-- Paths where Copilot should never be enabled
M.blocked_paths = {
  "%.env$",
  "%.env%..*",
  "secrets/",
  "%.secret$",
  "%.credentials$",
  "%.kube/config",
  "%.ssh/",
  "%.aws/",
  "%.azure/",
  "private/",
  "vault/",
}

-- Check if current file path should block Copilot
M.should_disable_copilot = function()
  local filepath = vim.fn.expand("%:p")
  
  for _, pattern in ipairs(M.blocked_paths) do
    if string.match(filepath, pattern) then
      return true
    end
  end
  
  return false
end

-- Auto-disable Copilot for blocked paths
vim.api.nvim_create_autocmd({"BufEnter", "BufNewFile"}, {
  pattern = "*",
  callback = function()
    if M.should_disable_copilot() then
      vim.cmd("Copilot disable")
      vim.notify("Copilot disabled for sensitive file", vim.log.levels.WARN)
    end
  end,
})

return M
```

**3. Create .copilotignore:**

```
# .copilotignore (workspace-level)
*.env
*.env.*
.envrc
secrets/
private/
.kube/
.ssh/
.aws/
.azure/
*.secret
*.credentials
*password*
*token*
terraform.tfvars
*.tfvars
```

**4. Add user notification:**

```lua
# nvim/.config/nvim/lua/config/copilot-notice.lua

-- Show notice when Copilot is active for first time
local shown_notice = false

vim.api.nvim_create_autocmd("User", {
  pattern = "CopilotAttach",
  callback = function()
    if not shown_notice then
      vim.notify(
        "⚠️  GitHub Copilot is sending your code to external servers.\n" ..
        "   Disabled for: .env, secrets/, terraform, yaml, json\n" ..
        "   See :help copilot-security for details",
        vim.log.levels.WARN
      )
      shown_notice = true
    end
  end,
})
```

**5. Add toggle command:**

```lua
# nvim/.config/nvim/lua/config/copilot-toggle.lua

-- Quick toggle for Copilot (when you need to work on sensitive files)
vim.api.nvim_create_user_command("CopilotSecure", function()
  vim.cmd("Copilot disable")
  vim.g.copilot_filetypes = { ["*"] = false }
  vim.notify("🔒 Copilot DISABLED (secure mode)", vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command("CopilotNormal", function()
  vim.cmd("Copilot enable")
  vim.g.copilot_filetypes = nil
  vim.notify("🔓 Copilot ENABLED (normal mode)", vim.log.levels.INFO)
end, {})

-- Keybindings
vim.keymap.set("n", "<leader>cs", ":CopilotSecure<CR>", { desc = "Copilot Secure Mode" })
vim.keymap.set("n", "<leader>cn", ":CopilotNormal<CR>", { desc = "Copilot Normal Mode" })
```

**6. Documentation:**

Create `_docs/COPILOT_SECURITY.md`:

```markdown
# GitHub Copilot Security

## Data Sent to External Servers

GitHub Copilot sends your code to Microsoft servers for AI processing.

## File Types Disabled

Copilot is disabled for:
- `.env` files and environment variables
- Terraform and infrastructure code
- YAML/JSON configuration files
- Shell scripts
- Anything in `secrets/` or `private/` directories

## Commands

- `:CopilotSecure` - Disable Copilot completely
- `:CopilotNormal` - Re-enable Copilot with restrictions
- `:Copilot disable` - Disable for current session

## Best Practices

1. Never use Copilot when working with:
   - Customer data
   - Proprietary algorithms
   - Security credentials
   - Unreleased features

2. Use `:CopilotSecure` mode when:
   - Working on work laptop
   - Handling sensitive code
   - Debugging production issues

3. For corporate use:
   - Use GitHub Copilot for Business (with data residency)
   - Configure organization-level restrictions
   - Disable for sensitive repositories
```

**Acceptance Criteria:**
- [ ] Copilot filetypes restricted to safe types only
- [ ] Path-based blocking implemented
- [ ] .copilotignore created
- [ ] User notification on first attach
- [ ] Toggle commands added (CopilotSecure/CopilotNormal)
- [ ] Documentation created
- [ ] Keybindings configured
- [ ] Tests for path blocking logic

---

### Issue #6: Implement dry-run mode for installation scripts

**Labels:** `security`, `P1-high`, `installation`, `safety`

**Description:**

Installation scripts make system-wide changes without preview option:
- Install packages
- Modify system services
- Create/delete directories
- Change shell configurations
- Add sudo permissions

Users cannot preview what will be changed before execution.

**Affected Files:**
- `_scripts/install.sh`
- `_scripts/install.ps1`
- `_scripts/bootstrap.sh`
- All scripts in `_scripts/unix/installers/`
- All scripts in `_scripts/windows/installers/`

**Recommendation:**

Add `--dry-run` / `-n` flag to preview changes:

**1. Update main installation script:**

```bash
# _scripts/install.sh

# Parse arguments
DRY_RUN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --full)
            INSTALL_MODE="full"
            shift
            ;;
        --minimal)
            INSTALL_MODE="minimal"
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Show dry-run banner
if [[ "$DRY_RUN" == "true" ]]; then
    log_header "DRY RUN MODE - No changes will be made"
    echo ""
fi
```

**2. Create execution wrapper:**

```bash
# _scripts/unix/lib/dry-run.sh

# Execute command or show what would be executed
execute() {
    local description="$1"
    shift
    local command="$*"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] $description"
        log_step "Would execute: $command"
        return 0
    else
        if [[ "$VERBOSE" == "true" ]]; then
            log_step "$description"
            log_info "Executing: $command"
        fi
        eval "$command"
        return $?
    fi
}

# Execute sudo command with dry-run support
execute_sudo() {
    local description="$1"
    shift
    local command="$*"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "[DRY RUN] $description (requires sudo)"
        log_step "Would execute: sudo $command"
        return 0
    else
        if [[ "$VERBOSE" == "true" ]]; then
            log_step "$description"
            log_info "Executing: sudo $command"
        fi
        sudo bash -c "$command"
        return $?
    fi
}

# File operation with dry-run support
execute_file_op() {
    local operation="$1"  # create, delete, modify
    local description="$2"
    shift 2
    local command="$*"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        case $operation in
            create)
                log_info "[DRY RUN] Would create: $description"
                ;;
            delete)
                log_warn "[DRY RUN] Would delete: $description"
                ;;
            modify)
                log_info "[DRY RUN] Would modify: $description"
                ;;
        esac
        log_step "Command: $command"
        return 0
    else
        eval "$command"
        return $?
    fi
}

export -f execute
export -f execute_sudo
export -f execute_file_op
```

**3. Update installation scripts to use wrappers:**

```bash
# Before (direct execution):
sudo apt-get install -y zsh

# After (with dry-run support):
execute_sudo "Install zsh shell" "apt-get install -y zsh"
```

```bash
# Before (direct file operations):
rm -rf "$HOME/.config/nvim"
git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"

# After (with dry-run support):
execute_file_op "delete" "$HOME/.config/nvim" "rm -rf '$HOME/.config/nvim'"
execute_file_op "create" "$HOME/.config/nvim from LazyVim" "git clone https://github.com/LazyVim/starter '$HOME/.config/nvim'"
```

**4. Add summary report:**

```bash
# _scripts/unix/lib/dry-run-report.sh

# Track what would be changed
declare -a DRY_RUN_ACTIONS=()

add_dry_run_action() {
    local category="$1"
    local description="$2"
    DRY_RUN_ACTIONS+=("$category: $description")
}

show_dry_run_summary() {
    if [[ "$DRY_RUN" != "true" ]]; then
        return 0
    fi
    
    echo ""
    log_header "DRY RUN SUMMARY"
    echo ""
    
    if [[ ${#DRY_RUN_ACTIONS[@]} -eq 0 ]]; then
        log_info "No changes would be made"
        return 0
    fi
    
    echo "The following changes would be made:"
    echo ""
    
    # Group by category
    local packages=()
    local files=()
    local system=()
    
    for action in "${DRY_RUN_ACTIONS[@]}"; do
        case $action in
            PACKAGE:*) packages+=("${action#PACKAGE: }");;
            FILE:*) files+=("${action#FILE: }");;
            SYSTEM:*) system+=("${action#SYSTEM: }");;
        esac
    done
    
    if [[ ${#packages[@]} -gt 0 ]]; then
        log_step "Packages (${#packages[@]}):"
        printf '  - %s\n' "${packages[@]}"
        echo ""
    fi
    
    if [[ ${#files[@]} -gt 0 ]]; then
        log_step "File Operations (${#files[@]}):"
        printf '  - %s\n' "${files[@]}"
        echo ""
    fi
    
    if [[ ${#system[@]} -gt 0 ]]; then
        log_warn "System Changes (${#system[@]}):"
        printf '  - %s\n' "${system[@]}"
        echo ""
    fi
    
    echo ""
    log_info "To apply these changes, run without --dry-run flag"
}

# Call at end of script
trap show_dry_run_summary EXIT
```

**5. PowerShell implementation:**

```powershell
# _scripts/windows/lib/dry-run.ps1

# Global dry-run state
$Global:DryRun = $false

function Invoke-DryRun {
    param(
        [string]$Description,
        [scriptblock]$Command
    )
    
    if ($Global:DryRun) {
        Write-Info "[DRY RUN] $Description"
        Write-Step "Would execute: $($Command.ToString())"
        return $null
    }
    else {
        Write-Step $Description
        & $Command
        return $?
    }
}

function Invoke-DryRunAdmin {
    param(
        [string]$Description,
        [scriptblock]$Command
    )
    
    if ($Global:DryRun) {
        Write-Warn "[DRY RUN] $Description (requires admin)"
        Write-Step "Would execute: $($Command.ToString())"
        return $null
    }
    else {
        if (-not (Test-IsAdmin)) {
            Write-Error "This operation requires administrator privileges"
            return $false
        }
        Write-Step $Description
        & $Command
        return $?
    }
}
```

**6. Update usage documentation:**

```bash
# _scripts/install.sh --help
Usage: install.sh [OPTIONS]

Options:
  --full              Install everything (default)
  --minimal           Install core tools only
  --dry-run, -n       Preview changes without making them
  --verbose, -v       Show detailed output
  --help, -h          Show this help message

Examples:
  # Preview what would be installed
  ./install.sh --dry-run

  # Preview minimal installation
  ./install.sh --minimal --dry-run

  # Verbose output with actual installation
  ./install.sh --full --verbose
```

**Acceptance Criteria:**
- [ ] `--dry-run` / `-n` flag implemented in all main scripts
- [ ] Execution wrappers created (execute, execute_sudo, execute_file_op)
- [ ] Dry-run summary report implemented
- [ ] PowerShell equivalent implemented
- [ ] All installer scripts updated to use wrappers
- [ ] Usage documentation updated
- [ ] Examples added to README
- [ ] Tests for dry-run mode

---

### Issue #7: Add confirmation prompts for destructive operations

**Labels:** `security`, `P1-high`, `ux`, `safety`

**Description:**

Scripts perform system-wide changes without explicit user confirmation:
- Installing system packages with sudo
- Modifying systemd services
- Deleting existing configurations
- Changing default shell

**Affected Files:**
- All installation scripts
- `_scripts/unix/tools/uninstall.sh`
- `_scripts/unix/installers/install-docker.sh`
- `_scripts/unix/installers/install-zsh.sh`

**Recommendation:**

Add confirmation prompts for high-impact operations.

**1. Enhance confirm_prompt function:**

```bash
# _scripts/unix/lib/common.sh (already exists, enhance it)

# Confirmation prompt with default
confirm_prompt() {
    local message="$1"
    local default="${2:-n}"  # Default to 'no' for safety
    local response
    
    if [[ "$NON_INTERACTIVE" == "true" ]] || [[ "$FORCE" == "true" ]]; then
        log_warn "Auto-confirming (non-interactive mode): $message"
        return 0
    fi
    
    # Color the prompt based on danger level
    if [[ "$message" =~ (delete|remove|destroy|format) ]]; then
        echo -ne "${RED}⚠️  $message${NC} "
    else
        echo -ne "${YELLOW}$message${NC} "
    fi
    
    if [[ "$default" == "y" ]]; then
        echo -n "[Y/n]: "
    else
        echo -n "[y/N]: "
    fi
    
    read -r response
    response=${response:-$default}
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        log_info "Operation cancelled by user"
        return 1
    fi
}

# More emphatic confirmation for dangerous operations
confirm_dangerous() {
    local message="$1"
    local confirm_word="${2:-DELETE}"
    
    if [[ "$NON_INTERACTIVE" == "true" ]] || [[ "$FORCE" == "true" ]]; then
        log_warn "Auto-confirming dangerous operation (non-interactive mode): $message"
        return 0
    fi
    
    echo ""
    log_warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_error "DANGEROUS OPERATION"
    echo -e "${RED}$message${NC}"
    log_warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -ne "${YELLOW}Type '${RED}$confirm_word${YELLOW}' to confirm: ${NC}"
    
    local response
    read -r response
    
    if [[ "$response" == "$confirm_word" ]]; then
        return 0
    else
        log_info "Operation cancelled (confirmation text did not match)"
        return 1
    fi
}
```

**2. Add confirmation to critical operations:**

```bash
# _scripts/unix/installers/install-docker.sh

install_docker() {
    log_header "Docker Installation"
    
    echo ""
    log_info "This will:"
    echo "  • Install Docker Engine, CLI, and Compose"
    echo "  • Add Docker's official GPG key"
    echo "  • Configure Docker repository"
    echo "  • Enable and start Docker service"
    echo "  • Add current user to docker group"
    echo ""
    
    confirm_prompt "Continue with Docker installation?" || {
        log_info "Installation cancelled"
        return 1
    }
    
    # Rest of installation...
}
```

```bash
# _scripts/unix/installers/install-zsh.sh

change_default_shell() {
    local zsh_path="$1"
    
    echo ""
    log_warn "This will change your default shell to zsh"
    log_info "Current shell: $SHELL"
    log_info "New shell: $zsh_path"
    echo ""
    log_warn "You will need to log out and log back in for this to take effect"
    echo ""
    
    confirm_prompt "Change default shell to zsh?" || {
        log_info "Shell change cancelled"
        log_info "You can change it later with: chsh -s $zsh_path"
        return 1
    }
    
    sudo chsh -s "$zsh_path" "$USER"
}
```

```bash
# _scripts/unix/installers/install-lazyvim.sh

backup_existing_config() {
    if [[ -d "$NVIM_CONFIG_PATH" ]]; then
        echo ""
        log_warn "Existing Neovim configuration found at:"
        echo "  $NVIM_CONFIG_PATH"
        echo ""
        log_info "Backup will be created at:"
        echo "  $NVIM_CONFIG_BACKUP"
        echo ""
        
        confirm_prompt "Backup and replace existing configuration?" || {
            log_error "Installation cancelled to preserve existing config"
            exit 1
        }
        
        # Create backup
        mv "$NVIM_CONFIG_PATH" "$NVIM_CONFIG_BACKUP"
        log_success "Backup created"
    fi
}
```

**3. Add --force and --yes flags:**

```bash
# _scripts/install.sh

# Parse arguments
FORCE=false
NON_INTERACTIVE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --force|-f)
            FORCE=true
            NON_INTERACTIVE=true
            log_warn "Force mode enabled - all prompts will be auto-confirmed"
            shift
            ;;
        --yes|-y)
            NON_INTERACTIVE=true
            log_warn "Non-interactive mode - all prompts will be auto-confirmed"
            shift
            ;;
        # ... other options
    esac
done

# Export for use in subscripts
export FORCE
export NON_INTERACTIVE
```

**4. Add operation summary before confirmation:**

```bash
# _scripts/install.sh

show_installation_summary() {
    log_header "Installation Summary"
    echo ""
    log_info "Installation mode: $INSTALL_MODE"
    log_info "Platform: $(detect_os)"
    echo ""
    
    log_step "The following will be installed:"
    echo ""
    
    case $INSTALL_MODE in
        full)
            echo "  📦 Packages:"
            echo "     • Essential tools (git, curl, wget, etc.)"
            echo "     • Shell tools (zsh, zinit, starship)"
            echo "     • Modern replacements (eza, bat, delta, etc.)"
            echo "     • Development tools (mise, just, etc.)"
            echo ""
            echo "  🔧 Configurations:"
            echo "     • Git configuration"
            echo "     • Shell configuration (zsh)"
            echo "     • Editor configuration (Neovim + LazyVim)"
            echo "     • Terminal configuration (WezTerm)"
            echo ""
            echo "  🔗 System changes:"
            echo "     • Symlink dotfiles with GNU Stow"
            echo "     • Change default shell to zsh (optional)"
            echo ""
            ;;
        minimal)
            echo "  📦 Packages:"
            echo "     • Essential tools only"
            echo ""
            echo "  🔧 Configurations:"
            echo "     • Basic git and shell setup"
            echo ""
            ;;
    esac
    
    log_warn "Some operations may require sudo privileges"
    echo ""
    
    confirm_prompt "Proceed with installation?" "y" || {
        log_info "Installation cancelled by user"
        exit 0
    }
}

# Call before starting installation
show_installation_summary
```

**5. Add uninstall confirmation:**

```bash
# _scripts/unix/tools/uninstall.sh

confirm_uninstall() {
    log_header "Dotfiles Uninstallation"
    echo ""
    log_error "This will:"
    echo "  • Remove all symlinked dotfiles"
    echo "  • Uninstall zinit plugin manager"
    echo "  • Restore backed-up configurations (if available)"
    echo ""
    log_warn "The following will NOT be removed:"
    echo "  • Installed packages (zsh, nvim, etc.)"
    echo "  • This dotfiles repository"
    echo ""
    
    confirm_dangerous "Are you sure you want to uninstall dotfiles?" "UNINSTALL" || {
        log_info "Uninstallation cancelled"
        exit 0
    }
}
```

**6. PowerShell implementation:**

```powershell
# _scripts/windows/lib/common.ps1

function Confirm-Action {
    param(
        [string]$Message,
        [string]$Default = "N"
    )
    
    if ($Global:Force -or $Global:NonInteractive) {
        Write-Warning "Auto-confirming (non-interactive mode): $Message"
        return $true
    }
    
    $prompt = if ($Default -eq "Y") { "[Y/n]" } else { "[y/N]" }
    $response = Read-Host "$Message $prompt"
    $response = if ([string]::IsNullOrWhiteSpace($response)) { $Default } else { $response }
    
    return $response -match '^[Yy]$'
}

function Confirm-DangerousAction {
    param(
        [string]$Message,
        [string]$ConfirmWord = "DELETE"
    )
    
    if ($Global:Force -or $Global:NonInteractive) {
        Write-Warning "Auto-confirming dangerous operation (non-interactive mode): $Message"
        return $true
    }
    
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host "DANGEROUS OPERATION" -ForegroundColor Red
    Write-Host $Message -ForegroundColor Red
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host ""
    
    $response = Read-Host "Type '$ConfirmWord' to confirm"
    
    return $response -eq $ConfirmWord
}
```

**Acceptance Criteria:**
- [ ] Enhanced confirm_prompt and confirm_dangerous functions
- [ ] Confirmation added to all critical operations
- [ ] Installation summary displayed before proceeding
- [ ] --force and --yes flags implemented
- [ ] Uninstall requires typing "UNINSTALL"
- [ ] PowerShell equivalents implemented
- [ ] Non-interactive mode for CI/automation
- [ ] Documentation updated with new flags

---

## P2 - Medium Priority (Plan to Fix)

### Issue #8: Pin package versions for reproducibility

**Labels:** `reliability`, `P2-medium`, `packages`, `reproducibility`

**Brief Description:**

All packages install latest version without pinning. This can cause:
- Breaking changes from major version updates
- Inconsistent installations across machines
- Security vulnerabilities from untested versions

**Affected Files:**
- `_scripts/configs/**/*.pkg.yml`
- `mise/config.toml`
- Package manager commands in installers

**Recommendation:**
- Add version field to package configs
- Pin critical tools to specific versions or version ranges
- Document update policy

**Example:**
```yaml
packages:
  - name: nodejs
    version: "20.x"  # LTS version range
  - name: python
    version: "3.11"  # Specific minor version
```

---

### Issue #9: Add package vulnerability scanning

**Labels:** `security`, `P2-medium`, `monitoring`, `packages`

**Brief Description:**

No vulnerability scanning for installed packages.

**Recommendation:**
- Create `_scripts/unix/tools/check-vulnerabilities.sh`
- Integrate with `npm audit`, `pip-audit`, `cargo-audit`
- Run as part of `just doctor` command

---

### Issue #10: Add interactive deletion protection

**Labels:** `safety`, `P2-medium`, `ux`, `shell`

**Brief Description:**

No protection against accidental file deletion with `rm` command.

**Recommendation:**

```zsh
# Option 1: Alias to interactive mode
alias rm='rm -i'

# Option 2: Use trash instead (recommended)
alias rm='trash'  # Requires: brew install trash

# Option 3: Prompt for recursive operations
alias rmr='rm -rI'  # Prompts before removing 3+ files
```

---

## P3 - Low Priority (Future Enhancement)

### Issue #11: Implement PowerShell script signing

**Labels:** `security`, `P3-low`, `windows`, `scripts`

**Brief:** Sign PowerShell scripts for additional security

---

### Issue #12: Add plugin version pinning

**Labels:** `reliability`, `P3-low`, `plugins`, `zsh`, `nvim`

**Brief:** Pin Zinit and Neovim plugin versions

---

### Issue #13: Separate public and private configurations

**Labels:** `architecture`, `P3-low`, `privacy`

**Brief:** Create separate private repository for sensitive configs

---

### Issue #14: Add git-secrets integration

**Labels:** `security`, `P3-low`, `git`, `secrets`

**Brief:** Additional secret scanning with git-secrets tool

---

## Summary by Priority

| Priority | Count | Action Timeframe |
|----------|-------|------------------|
| **P0 - Critical** | 3 | Fix immediately (this week) |
| **P1 - High** | 4 | Fix soon (this month) |
| **P2 - Medium** | 3 | Plan to fix (this quarter) |
| **P3 - Low** | 4 | Future enhancement (backlog) |

---

## Next Steps

1. Review and validate all issues
2. Create GitHub issues from this list
3. Prioritize based on your use case (work vs personal)
4. Start with P0 issues
5. Track progress in project board

---

**Generated:** February 6, 2026  
**Based on:** SECURITY-DOTFILES.md audit report  
**Total Issues:** 14
