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
alias gapa = git add --patch
alias gau = git add --update
alias gav = git add --verbose

# Branch
alias gb = git branch
alias gba = git branch --all
alias gbd = git branch --delete
alias gbD = git branch --delete --force
alias gbm = git branch --move
alias gbnm = git branch --no-merged
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
alias gca = git commit --verbose --all
alias "gca!" = git commit --verbose --all --amend
alias "gcan!" = git commit --verbose --all --no-edit --amend
alias gcam = git commit --all --message
alias gcas = git commit --all --signoff
alias gcasm = git commit --all --signoff --message
alias gcmsg = git commit --message
alias gcsm = git commit --signoff --message

# Config
alias gcf = git config --list

# Diff
alias gd = git diff
alias gdca = git diff --cached
alias gdcw = git diff --cached --word-diff
alias gds = git diff --staged
alias gdw = git diff --word-diff
alias gdup = git diff '@{upstream}'

# Fetch
alias gf = git fetch
alias gfa = git fetch --all --tags --prune
alias gfo = git fetch origin

# Pull
alias gl = git pull
alias gpr = git pull --rebase
alias gpra = git pull --rebase --autostash

def gprom [] { git pull --rebase origin (git-main-branch) }
def gprum [] { git pull --rebase upstream (git-main-branch) }

# Log
alias glg = git log --stat
alias glgp = git log --stat --patch
alias glgg = git log --graph
alias glgga = git log --graph --decorate --all
alias glgm = git log --graph --max-count=10
alias glo = git log --oneline --decorate
alias glog = git log --oneline --decorate --graph
alias gloga = git log --oneline --decorate --graph --all
alias glol = git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'
alias glola = git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all
alias glols = git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat

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
alias gpf = git push --force-with-lease --force-if-includes
alias "gpf!" = git push --force
alias gpoat = git push origin --all; git push origin --tags
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

# Rebase
alias grb = git rebase
alias grba = git rebase --abort
alias grbc = git rebase --continue
alias grbi = git rebase --interactive
alias grbo = git rebase --onto
alias grbs = git rebase --skip

def grbd [] { git rebase (git-develop-branch) }
def grbm [] { git rebase (git-main-branch) }
def grbom [] { git rebase $"origin/(git-main-branch)" }

# Remote
alias gr = git remote
alias gra = git remote add
alias grrm = git remote remove
alias grmv = git remote rename
alias grset = git remote set-url
alias grup = git remote update
alias grv = git remote --verbose

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

# Revert
alias grev = git revert
alias greva = git revert --abort
alias grevc = git revert --continue

# Remove
alias grm = git rm
alias grmc = git rm --cached

# Show
alias gsh = git show
alias gsps = git show --pretty=short --show-signature

# Stash
alias gsta = git stash push
alias gstaa = git stash apply
alias gstall = git stash --all
alias gstc = git stash clear
alias gstd = git stash drop
alias gstl = git stash list
alias gstp = git stash pop
alias gsts = git stash show --patch
alias gstu = git stash --include-untracked

# Status
alias gst = git status
alias gss = git status --short
alias gsb = git status --short --branch

# Switch (Git 2.23+)
alias gsw = git switch
alias gswc = git switch --create

def gswd [] { git switch (git-develop-branch) }
def gswm [] { git switch (git-main-branch) }

# Tag
alias gta = git tag --annotate
alias gts = git tag --sign
alias gtv = git tag | sort --natural

# Worktree
alias gwt = git worktree
alias gwta = git worktree add
alias gwtls = git worktree list
alias gwtmv = git worktree move
alias gwtrm = git worktree remove

# Cherry-pick
alias gcp = git cherry-pick
alias gcpa = git cherry-pick --abort
alias gcpc = git cherry-pick --continue

# Reflog
alias grf = git reflog

# Bisect
alias gbs = git bisect
alias gbsb = git bisect bad
alias gbsg = git bisect good
alias gbsr = git bisect reset
alias gbss = git bisect start

# Submodule
alias gsi = git submodule init
alias gsu = git submodule update

# WIP (Work in Progress)
def gwip [] {
    git add -A
    git rm (git ls-files --deleted) | ignore
    git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"
}

def gunwip [] {
    let last_commit = (git log -1 --pretty=%B)
    if ($last_commit =~ '--wip--') {
        git reset HEAD~1
    }
}

# Ignore/Unignore
alias gignore = git update-index --assume-unchanged
alias gunignore = git update-index --no-assume-unchanged

def gignored [] {
    git ls-files -v | lines | where { $in | str starts-with (char -u 61) }
}

# Utilities
alias gcount = git shortlog --summary --numbered

def gfg [pattern: string] {
    git ls-files | lines | where { $in =~ $pattern }
}
