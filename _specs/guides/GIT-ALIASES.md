# Git Aliases Reference

This document provides a quick reference for the Oh My Zsh-style git aliases available in both PowerShell and Nushell.

> **Source**: Based on [Oh My Zsh Git Plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git)

## Quick Start

The git aliases are automatically loaded when you start PowerShell or Nushell (after stowing the respective profiles).

**Verify it's working**:
```powershell
# PowerShell or Nushell
gst                    # Same as: git status
glog                   # Same as: git log --oneline --decorate --graph
```

## Most Common Aliases

### Status & Info
| Alias | Command | Description |
|-------|---------|-------------|
| `gst` | `git status` | Show working tree status |
| `gss` | `git status --short` | Short status |
| `gsb` | `git status --short --branch` | Short status with branch info |
| `glog` | `git log --oneline --decorate --graph` | Pretty graph log |
| `glol` | Pretty colored log | Graph log with colors |
| `glola` | Pretty colored log --all | Graph log with all branches |

### Branch Management
| Alias | Command | Description |
|-------|---------|-------------|
| `gb` | `git branch` | List branches |
| `gba` | `git branch --all` | List all branches (local + remote) |
| `gbd` | `git branch --delete` | Delete branch |
| `gbD` | `git branch --delete --force` | Force delete branch |
| `gcb` | `git checkout -b` | Create and checkout new branch |
| `gcm` | `git checkout main/master` | Checkout main branch (auto-detects) |
| `gswm` | `git switch main/master` | Switch to main branch (Git 2.23+) |

### Add & Commit
| Alias | Command | Description |
|-------|---------|-------------|
| `ga` | `git add` | Add files |
| `gaa` | `git add --all` | Add all changes |
| `gapa` | `git add --patch` | Interactive add |
| `gc` | `git commit --verbose` | Commit with verbose output |
| `gcam` | `git commit --all --message` | Commit all with message |
| `gcmsg` | `git commit --message` | Commit with message |
| `gca!` | `git commit --all --amend` | Amend previous commit |
| `gcan!` | `git commit --all --no-edit --amend` | Amend without editing message |

### Push & Pull
| Alias | Command | Description |
|-------|---------|-------------|
| `gp` | `git push` | Push to remote |
| `gpsup` | Push with set-upstream | Push and set upstream to origin |
| `gpf` | `git push --force-with-lease` | Safe force push |
| `gpf!` | `git push --force` | Force push (dangerous!) |
| `gl` | `git pull` | Pull from remote |
| `gpr` | `git pull --rebase` | Pull with rebase |
| `gpra` | `git pull --rebase --autostash` | Pull rebase with autostash |
| `gprom` | Pull rebase from origin/main | Pull rebase from main branch |

### Diff
| Alias | Command | Description |
|-------|---------|-------------|
| `gd` | `git diff` | Show changes |
| `gdca` | `git diff --cached` | Show staged changes |
| `gds` | `git diff --staged` | Show staged changes |
| `gdw` | `git diff --word-diff` | Word-level diff |

### Checkout & Switch
| Alias | Command | Description |
|-------|---------|-------------|
| `gco` | `git checkout` | Checkout branch/files |
| `gcb` | `git checkout -b` | Create and checkout branch |
| `gcm` | Checkout main/master | Checkout main branch (auto-detects) |
| `gcd` | Checkout develop | Checkout develop branch |
| `gsw` | `git switch` | Switch branches (Git 2.23+) |
| `gswc` | `git switch --create` | Create and switch to branch |

### Stash
| Alias | Command | Description |
|-------|---------|-------------|
| `gsta` | `git stash push` | Stash changes |
| `gstaa` | `git stash apply` | Apply stash |
| `gstl` | `git stash list` | List stashes |
| `gstp` | `git stash pop` | Pop latest stash |
| `gstd` | `git stash drop` | Drop stash |
| `gstc` | `git stash clear` | Clear all stashes |

### Reset & Clean
| Alias | Command | Description |
|-------|---------|-------------|
| `grh` | `git reset` | Reset HEAD |
| `grhh` | `git reset --hard` | Hard reset |
| `grhs` | `git reset --soft` | Soft reset |
| `gpristine` | Hard reset + clean | Reset and remove all changes |

### Rebase
| Alias | Command | Description |
|-------|---------|-------------|
| `grb` | `git rebase` | Rebase current branch |
| `grbi` | `git rebase --interactive` | Interactive rebase |
| `grba` | `git rebase --abort` | Abort rebase |
| `grbc` | `git rebase --continue` | Continue rebase |
| `grbm` | Rebase on main | Rebase on main branch |

## Complete Alias List

### Add
- `ga` - git add
- `gaa` - git add --all
- `gapa` - git add --patch
- `gau` - git add --update
- `gav` - git add --verbose

### Branch
- `gb` - git branch
- `gba` - git branch --all
- `gbd` - git branch --delete
- `gbD` - git branch --delete --force
- `gbm` - git branch --move
- `gbnm` - git branch --no-merged
- `gbr` - git branch --remote

### Checkout
- `gco` - git checkout
- `gcb` - git checkout -b
- `gcB` - git checkout -B
- `gcm` - git checkout main/master
- `gcd` - git checkout develop

### Clone
- `gcl` - git clone --recurse-submodules

### Commit
- `gc` - git commit --verbose
- `gc!` - git commit --verbose --amend
- `gcn!` - git commit --verbose --no-edit --amend
- `gca` - git commit --verbose --all
- `gca!` - git commit --verbose --all --amend
- `gcan!` - git commit --verbose --all --no-edit --amend
- `gcam` - git commit --all --message
- `gcas` - git commit --all --signoff
- `gcasm` - git commit --all --signoff --message
- `gcmsg` - git commit --message
- `gcsm` - git commit --signoff --message

### Config
- `gcf` - git config --list

### Diff
- `gd` - git diff
- `gdca` - git diff --cached
- `gdcw` - git diff --cached --word-diff
- `gds` - git diff --staged
- `gdw` - git diff --word-diff
- `gdup` - git diff @{upstream}

### Fetch
- `gf` - git fetch
- `gfa` - git fetch --all --tags --prune
- `gfo` - git fetch origin

### Log
- `gl` - git pull
- `glg` - git log --stat
- `glgp` - git log --stat --patch
- `glgg` - git log --graph
- `glgga` - git log --graph --decorate --all
- `glgm` - git log --graph --max-count=10
- `glo` - git log --oneline --decorate
- `glog` - git log --oneline --decorate --graph
- `gloga` - git log --oneline --decorate --graph --all
- `glol` - Pretty graph log with colors
- `glola` - Pretty graph log --all with colors
- `glols` - Pretty graph log with stats

### Merge
- `gm` - git merge
- `gma` - git merge --abort
- `gmc` - git merge --continue
- `gms` - git merge --squash
- `gmom` - git merge origin/main
- `gmum` - git merge upstream/main

### Push
- `gp` - git push
- `gpd` - git push --dry-run
- `gpf` - git push --force-with-lease --force-if-includes
- `gpf!` - git push --force
- `gpoat` - git push origin --all && git push origin --tags
- `gpod` - git push origin --delete
- `gpu` - git push upstream
- `gpv` - git push --verbose
- `gpsup` - git push --set-upstream origin [current-branch]
- `gpsupf` - git push --set-upstream --force-with-lease

### Pull
- `gl` - git pull
- `gpr` - git pull --rebase
- `gpra` - git pull --rebase --autostash
- `gprom` - git pull --rebase origin main
- `gprum` - git pull --rebase upstream main

### Rebase
- `grb` - git rebase
- `grba` - git rebase --abort
- `grbc` - git rebase --continue
- `grbi` - git rebase --interactive
- `grbo` - git rebase --onto
- `grbs` - git rebase --skip
- `grbd` - git rebase develop
- `grbm` - git rebase main
- `grbom` - git rebase origin/main

### Remote
- `gr` - git remote
- `gra` - git remote add
- `grrm` - git remote remove
- `grmv` - git remote rename
- `grset` - git remote set-url
- `grup` - git remote update
- `grv` - git remote --verbose

### Reset
- `grh` - git reset
- `grhh` - git reset --hard
- `grhk` - git reset --keep
- `grhs` - git reset --soft
- `gpristine` - git reset --hard && git clean -dfx

### Restore
- `grs` - git restore
- `grst` - git restore --staged
- `grss` - git restore --source

### Revert
- `grev` - git revert
- `greva` - git revert --abort
- `grevc` - git revert --continue

### Remove
- `grm` - git rm
- `grmc` - git rm --cached

### Show
- `gsh` - git show
- `gsps` - git show --pretty=short --show-signature

### Stash
- `gsta` - git stash push
- `gstaa` - git stash apply
- `gstall` - git stash --all
- `gstc` - git stash clear
- `gstd` - git stash drop
- `gstl` - git stash list
- `gstp` - git stash pop
- `gsts` - git stash show --patch
- `gstu` - git stash --include-untracked

### Status
- `gst` - git status
- `gss` - git status --short
- `gsb` - git status --short --branch

### Switch (Git 2.23+)
- `gsw` - git switch
- `gswc` - git switch --create
- `gswd` - git switch develop
- `gswm` - git switch main

### Tag
- `gta` - git tag --annotate
- `gts` - git tag --sign
- `gtv` - git tag (sorted)

### Worktree
- `gwt` - git worktree
- `gwta` - git worktree add
- `gwtls` - git worktree list
- `gwtmv` - git worktree move
- `gwtrm` - git worktree remove

### Cherry-pick
- `gcp` - git cherry-pick
- `gcpa` - git cherry-pick --abort
- `gcpc` - git cherry-pick --continue

### Reflog
- `grf` - git reflog

### Bisect
- `gbs` - git bisect
- `gbsb` - git bisect bad
- `gbsg` - git bisect good
- `gbsr` - git bisect reset
- `gbss` - git bisect start

### Submodule
- `gsi` - git submodule init
- `gsu` - git submodule update

### Work in Progress (WIP)
- `gwip` - Create WIP commit
- `gunwip` - Undo WIP commit

### Ignore
- `gignore` - git update-index --assume-unchanged
- `gunignore` - git update-index --no-assume-unchanged
- `gignored` - List ignored files

### Utilities
- `gcount` - git shortlog --summary --numbered
- `gfg` - git ls-files | grep

## Smart Features

### Auto-Detection
- `gcm` - Automatically checks out `main`, `trunk`, `mainline`, `default`, `stable`, or `master` (in that order)
- `gcd` - Automatically checks out `dev`, `devel`, `develop`, or `development`
- `gpsup` - Automatically detects current branch name

### Safe Defaults
- `gpf` - Uses `--force-with-lease --force-if-includes` instead of dangerous `--force`
- `gpf!` - Available if you really need `--force` (use with caution!)

## Platform Compatibility

All aliases work identically in:
- ✅ **PowerShell 7+** (Windows, Linux, macOS)
- ✅ **Nushell** (Windows, Linux, macOS)

## Examples

### Common Workflows

**Feature branch workflow**:
```powershell
gcm                    # Checkout main
gl                     # Pull latest
gcb feature/my-feature # Create feature branch
# ... make changes ...
gaa                    # Stage all
gcam "Add feature"     # Commit with message
gpsup                  # Push and set upstream
```

**Quick commit workflow**:
```powershell
gst                    # Check status
gaa                    # Stage all
gcam "Quick fix"       # Commit all with message
gp                     # Push
```

**View history**:
```powershell
glog                   # Simple graph
glola                  # Detailed graph with all branches
glol --since="2 weeks ago"  # Recent commits
```

**Stash workflow**:
```powershell
gsta                   # Stash changes
gcm                    # Switch branch
# ... do work ...
gco -                  # Return to previous branch
gstp                   # Pop stash
```

## See Also

- [Oh My Zsh Git Plugin Documentation](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git)
- [PowerShell git-aliases.ps1](../powershell/Documents/PowerShell/git-aliases.ps1)
- [Nushell git-aliases.nu](../nushell/.config/nushell/git-aliases.nu)
