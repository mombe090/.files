# Environment Variables Setup Guide

This guide explains how to configure environment variables for your shell using the provided sample files.

## 📁 Sample Files

Sample files are provided for different shells:

### Main Environment Files

```text
zsh/.envrc.sample                        # Zsh/Bash environment variables (direnv)
zsh/.env.sample                          # Zsh/Bash simple env file
nushell/.config/nushell/env.nu.sample    # Nushell environment
powershell/.config/powershell/env.ps1.sample  # PowerShell environment
```

### Private Environment Files (for secrets)

```text
zsh/.private.envrc.sample                        # Zsh/Bash private variables
nushell/.config/nushell/env.private.nu.sample    # Nushell private variables
powershell/.config/powershell/env.private.ps1.sample  # PowerShell private variables
```

**Separation of Concerns:**

- **Main files** (`.envrc`, `env.local.nu`, `env.local.ps1`): Standard configuration (USER_FULLNAME, USER_EMAIL, PC_TYPE)
- **Private files** (`.private.envrc`, `env.private.nu`, `env.private.ps1`): Sensitive credentials (API keys, passwords, tokens)

## 🔐 Security Notice

**⚠️ IMPORTANT:** Never commit files containing actual credentials!

The sample files use placeholder values. When you create your local copies, they should:

- ✅ Contain your real credentials
- ❌ **NEVER** be committed to git
- ✅ Be listed in `.gitignore`

## 🚀 Setup Instructions

### For Zsh/Bash (macOS/Linux)

#### Option 1: Using `.envrc` (Recommended with direnv)

```bash
# 1. Copy the main environment file
cp ~/.files/zsh/.envrc.sample ~/.envrc

# 2. Copy the private environment file (for secrets)
cp ~/.files/zsh/.private.envrc.sample ~/.private.envrc

# 3. Edit the main file with your basic config
nvim ~/.envrc

# 4. Edit the private file with your secrets
nvim ~/.private.envrc
chmod 600 ~/.private.envrc  # Restrict permissions

# 5. Allow direnv to load it
direnv allow ~

# 6. Restart your shell
exec $SHELL -l
```

**Benefits:**

- Per-directory environment loading
- Automatic activation when entering directories
- Better security (secrets separated from config)
- Private file automatically loaded by main .envrc

#### Option 2: Using `.env` (Simple)

```bash
# 1. Copy the sample file
cp ~/.files/zsh/.env.sample ~/.env

# 2. Edit with your actual values
nvim ~/.env

# 3. Restart your shell
exec $SHELL -l
```

**Benefits:**

- Simpler setup (no direnv needed)
- Global environment variables

---

### For Nushell

```bash
# 1. Copy the main environment file
cp ~/.files/nushell/.config/nushell/env.nu.sample ~/.config/nushell/env.local.nu

# 2. Copy the private environment file (for secrets)
cp ~/.files/nushell/.config/nushell/env.private.nu.sample ~/.config/nushell/env.private.nu

# 3. Edit the main file with your basic config
nvim ~/.config/nushell/env.local.nu

# 4. Edit the private file with your secrets
nvim ~/.config/nushell/env.private.nu

# 5. Restart Nushell
exit
nu
```

**Note:** The private file is automatically loaded by env.local.nu

---

### For PowerShell (Windows/Cross-platform)

```powershell
# 1. Copy the main environment file
Copy-Item $HOME/.files/powershell/.config/powershell/env.ps1.sample $HOME/.config/powershell/env.local.ps1

# 2. Copy the private environment file (for secrets)
Copy-Item $HOME/.files/powershell/.config/powershell/env.private.ps1.sample $HOME/.config/powershell/env.private.ps1

# 3. Edit the main file with your basic config
code $HOME/.config/powershell/env.local.ps1

# 4. Edit the private file with your secrets
code $HOME/.config/powershell/env.private.ps1

# 5. Reload your profile
. $PROFILE
```

**Note:** The private file is automatically loaded by env.local.ps1

---

## 📋 Required Variables

At minimum, configure these variables for the dotfiles to work properly:

| Variable | Description | Example |
|----------|-------------|---------|
| `USER_FULLNAME` | Your full name (for git config) | `"John Doe"` |
| `USER_EMAIL` | Your email (for git config) | `"john@example.com"` |
| `PERSONAL_USER` | Your username (for personal machine detection) | `"johndoe"` |
| `PC_TYPE` | Machine type | `"pro"` or `"perso"` |

## 🔧 Optional Variables

Add these only if you need them:

- **AWS**: `AWS_DEFAULT_REGION`
- **Kubernetes**: `KUBECONFIG`
- **AI Services**: `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`

You can add any custom variables you need in the "Custom Variables" section of your local env files.

## 🛡️ Security Best Practices

1. **Never commit actual credential files**

   ```bash
   # Add to .gitignore
   echo ".env" >> ~/.gitignore
   echo ".envrc" >> ~/.gitignore
   echo "env.local.nu" >> ~/.config/nushell/.gitignore
   echo "env.local.ps1" >> ~/.config/powershell/.gitignore
   ```

2. **Use different credentials for different environments**
   - Separate credentials for `pro` (work) and `perso` (personal)
   - Use `PC_TYPE` variable to switch behavior

3. **Rotate credentials regularly**
   - Change API keys and passwords periodically
   - Revoke unused tokens

4. **Use secret management tools** (Advanced)
   - Consider using `pass`, `1Password CLI`, or `Bitwarden CLI`
   - Reference secrets from vaults instead of storing them in plain text

## 🔍 Verification

After setup, verify your configuration:

```bash
# Check if variables are loaded
echo $USER_FULLNAME
echo $USER_EMAIL
echo $PC_TYPE

# For PowerShell
Write-Host $env:USER_FULLNAME
Write-Host $env:USER_EMAIL
Write-Host $env:PC_TYPE

# For Nushell
echo $env.USER_FULLNAME
echo $env.USER_EMAIL
echo $env.PC_TYPE
```

## 📚 Additional Resources

- [direnv documentation](https://direnv.net/)
- [Nushell environment](https://www.nushell.sh/book/environment.html)
- [PowerShell about_Environment_Variables](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_environment_variables)

## 🆘 Troubleshooting

### Variables not loading in Zsh

1. Check if direnv is installed: `command -v direnv`
2. Check if direnv hook is in `.zshrc`: `grep direnv ~/.zshrc`
3. Manually source: `source ~/.envrc` or `source ~/.env`

### Variables not loading in Nushell

1. Check if `env.local.nu` exists: `ls ~/.config/nushell/env.local.nu`
2. Check if it's sourced in `env.nu`: `cat ~/.config/nushell/env.nu | grep env.local`
3. Restart Nushell completely

### Variables not loading in PowerShell

1. Check if profile exists: `Test-Path $PROFILE`
2. Check if env.local.ps1 is sourced: `cat $PROFILE | Select-String env.local`
3. Reload profile: `. $PROFILE`

---

**Note:** This guide assumes you're using the dotfiles from this repository. Adjust paths accordingly if you've customized your setup.
