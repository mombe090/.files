# =============================================================================
# Git Aliases - Based on Oh My Zsh git plugin
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
# =============================================================================

# Helper functions
def git-main-branch [] {
    let branches = ['main' 'trunk' 'mainline' 'default' 'stable' 'master']
    for branch in $branches {
        let exists = (git show-ref -q --verify $"refs/heads/($branch)" | complete | get exit_code) == 0
        if $exists {
            return $branch
        }
    }
    return 'master'
}

def git-develop-branch [] {
    let branches = ['dev' 'devel' 'develop' 'development']
    for branch in $branches {
        let exists = (git show-ref -q --verify $"refs/heads/($branch)" | complete | get exit_code) == 0
        if $exists {
            return $branch
        }
    }
    return 'develop'
}

def git-current-branch [] {
    git branch --show-current 2>/dev/null
}

# =============================================================================
# Basic Aliases
# =============================================================================

alias g = git

# Add
alias ga = git add
alias gaa = git add --all

# Branch
alias gb = git branch
alias gba = git branch --all
alias gbd = git branch --delete
alias gbD = git branch --delete --force
alias gbr = git branch --remote

# Checkout
alias gco = git checkout
alias gcb = git checkout -b
alias gcB = git checkout -B

def gcm [] { git checkout (git-main-branch) }
def gcd [] { git checkout (git-develop-branch) }

# Clone
alias gcl = git clone --recurse-submodules

# Commit
alias gc = git commit --verbose
alias "gc!" = git commit --verbose --amend
alias "gcn!" = git commit --verbose --no-edit --amend

# Config
alias gcf = git config --list

# Diff
alias gd = git diff

# Fetch
alias gf = git fetch
alias gfa = git fetch --all --tags --prune
alias gfo = git fetch origin

# Pull
alias gl = git pull
alias gpr = git pull --rebase

# Log
alias glg = git log --stat
alias glgp = git log --stat --patch

# Merge
alias gm = git merge
alias gma = git merge --abort
alias gmc = git merge --continue
alias gms = git merge --squash

def gmom [] { git merge $"origin/(git-main-branch)" }
def gmum [] { git merge $"upstream/(git-main-branch)" }

# Push
alias gp = git push
alias gpd = git push --dry-run
alias gpod = git push origin --delete
alias gpu = git push upstream
alias gpv = git push --verbose

# Push with set-upstream
def gpsup [] {
    let branch = (git-current-branch)
    if ($branch | is-empty) {
        print "Not on any branch"
    } else {
        git push --set-upstream origin $branch
    }
}

def gpsupf [] {
    let branch = (git-current-branch)
    if ($branch | is-empty) {
        print "Not on any branch"
    } else {
        git push --set-upstream origin $branch --force-with-lease --force-if-includes
    }
}

# Remote
alias gr = git remote
alias gra = git remote add

# Reset
alias grh = git reset
alias grhh = git reset --hard
alias grhk = git reset --keep
alias grhs = git reset --soft

def gpristine [] {
    git reset --hard
    git clean --force -dfx
}

# Restore
alias grs = git restore
alias grst = git restore --staged
alias grss = git restore --source


# Remove
alias grm = git rm

# Status
alias gst = git status

# Switch (Git 2.23+)
alias gsw = git switch
alias gswc = git switch --create

def gswd [] { git switch (git-develop-branch) }
def gswm [] { git switch (git-main-branch) }
