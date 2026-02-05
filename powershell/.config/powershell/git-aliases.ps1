# =============================================================================
# Git Aliases - Based on Oh My Zsh git plugin
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
# =============================================================================

if (Get-Command git -ErrorAction SilentlyContinue) {

    # Helper function to get main branch name
    function Get-GitMainBranch {
        $branches = @('main', 'trunk', 'mainline', 'default', 'stable', 'master')
        foreach ($branch in $branches) {
            if (git show-ref -q --verify "refs/heads/$branch" 2>$null) {
                return $branch
            }
        }
        return 'master'
    }

    # Helper function to get develop branch name
    function Get-GitDevelopBranch {
        $branches = @('dev', 'devel', 'develop', 'development')
        foreach ($branch in $branches) {
            if (git show-ref -q --verify "refs/heads/$branch" 2>$null) {
                return $branch
            }
        }
        return 'develop'
    }

    # Helper function to get current branch
    function Get-GitCurrentBranch {
        $branch = git branch --show-current 2>$null
        if ($branch) { return $branch }
        return $null
    }

    # =============================================================================
    # Basic Aliases
    # =============================================================================

    function g { git @args }

    # Add
    function ga { git add @args }
    function gaa { git add --all @args }
    function gapa { git add --patch @args }
    function gau { git add --update @args }
    function gav { git add --verbose @args }

    # Branch
    function gb { git branch @args }
    function gba { git branch --all @args }
    function gbd { git branch --delete @args }
    function gbD { git branch --delete --force @args }
    function gbm { git branch --move @args }
    function gbnm { git branch --no-merged @args }
    function gbr { git branch --remote @args }

    # Checkout
    function gco { git checkout @args }
    function gcb { git checkout -b @args }
    function gcB { git checkout -B @args }
    function gcm { git checkout (Get-GitMainBranch) }
    function gcd { git checkout (Get-GitDevelopBranch) }

    # Clone
    function gcl { git clone --recurse-submodules @args }

    # Commit
    function gc { git commit --verbose @args }
    function gc! { git commit --verbose --amend @args }
    function gcn! { git commit --verbose --no-edit --amend @args }
    function gca { git commit --verbose --all @args }
    function gca! { git commit --verbose --all --amend @args }
    function gcan! { git commit --verbose --all --no-edit --amend @args }
    function gcam { git commit --all --message @args }
    function gcas { git commit --all --signoff @args }
    function gcasm { git commit --all --signoff --message @args }
    function gcmsg { git commit --message @args }
    function gcsm { git commit --signoff --message @args }

    # Config
    function gcf { git config --list @args }

    # Diff
    function gd { git diff @args }
    function gdca { git diff --cached @args }
    function gdcw { git diff --cached --word-diff @args }
    function gds { git diff --staged @args }
    function gdw { git diff --word-diff @args }
    function gdup { git diff '@{upstream}' @args }

    # Fetch
    function gf { git fetch @args }
    function gfa { git fetch --all --tags --prune @args }
    function gfo { git fetch origin @args }

    # Log
    function gl { git pull @args }
    function glg { git log --stat @args }
    function glgp { git log --stat --patch @args }
    function glgg { git log --graph @args }
    function glgga { git log --graph --decorate --all @args }
    function glgm { git log --graph --max-count=10 @args }
    function glo { git log --oneline --decorate @args }
    function glog { git log --oneline --decorate --graph @args }
    function gloga { git log --oneline --decorate --graph --all @args }
    function glol { git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' @args }
    function glola { git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all @args }
    function glols { git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat @args }

    # Merge
    function gm { git merge @args }
    function gma { git merge --abort @args }
    function gmc { git merge --continue @args }
    function gms { git merge --squash @args }
    function gmom { git merge "origin/$(Get-GitMainBranch)" @args }
    function gmum { git merge "upstream/$(Get-GitMainBranch)" @args }

    # Pull
    function gpr { git pull --rebase @args }
    function gpra { git pull --rebase --autostash @args }
    function gprom { git pull --rebase origin (Get-GitMainBranch) }
    function gprum { git pull --rebase upstream (Get-GitMainBranch) }

    # Push
    function gp { git push @args }
    function gpd { git push --dry-run @args }
    function gpf { git push --force-with-lease --force-if-includes @args }
    function gpf! { git push --force @args }
    function gpoat { git push origin --all; git push origin --tags }
    function gpod { git push origin --delete @args }
    function gpr { git push --rebase @args }
    function gpu { git push upstream @args }
    function gpv { git push --verbose @args }

    # Push with set-upstream
    function gpsup {
        $branch = Get-GitCurrentBranch
        if ($branch) {
            git push --set-upstream origin $branch
        } else {
            Write-Host "Not on any branch" -ForegroundColor Red
        }
    }

    function gpsupf {
        $branch = Get-GitCurrentBranch
        if ($branch) {
            git push --set-upstream origin $branch --force-with-lease --force-if-includes
        } else {
            Write-Host "Not on any branch" -ForegroundColor Red
        }
    }

    # Rebase
    function grb { git rebase @args }
    function grba { git rebase --abort @args }
    function grbc { git rebase --continue @args }
    function grbi { git rebase --interactive @args }
    function grbo { git rebase --onto @args }
    function grbs { git rebase --skip @args }
    function grbd { git rebase (Get-GitDevelopBranch) }
    function grbm { git rebase (Get-GitMainBranch) }
    function grbom { git rebase "origin/$(Get-GitMainBranch)" }

    # Remote
    function gr { git remote @args }
    function gra { git remote add @args }
    function grrm { git remote remove @args }
    function grmv { git remote rename @args }
    function grset { git remote set-url @args }
    function grup { git remote update @args }
    function grv { git remote --verbose @args }

    # Reset
    function grh { git reset @args }
    function grhh { git reset --hard @args }
    function grhk { git reset --keep @args }
    function grhs { git reset --soft @args }
    function gpristine { git reset --hard; git clean --force -dfx }

    # Restore
    function grs { git restore @args }
    function grst { git restore --staged @args }
    function grss { git restore --source @args }

    # Revert
    function grev { git revert @args }
    function greva { git revert --abort @args }
    function grevc { git revert --continue @args }

    # Remove
    function grm { git rm @args }
    function grmc { git rm --cached @args }

    # Show
    function gsh { git show @args }
    function gsps { git show --pretty=short --show-signature @args }

    # Stash
    function gsta { git stash push @args }
    function gstaa { git stash apply @args }
    function gstall { git stash --all @args }
    function gstc { git stash clear @args }
    function gstd { git stash drop @args }
    function gstl { git stash list @args }
    function gstp { git stash pop @args }
    function gsts { git stash show --patch @args }
    function gstu { git stash --include-untracked @args }

    # Status
    function gst { git status @args }
    function gss { git status --short @args }
    function gsb { git status --short --branch @args }

    # Switch (Git 2.23+)
    function gsw { git switch @args }
    function gswc { git switch --create @args }
    function gswd { git switch (Get-GitDevelopBranch) }
    function gswm { git switch (Get-GitMainBranch) }

    # Tag
    function gta { git tag --annotate @args }
    function gts { git tag --sign @args }
    function gtv { git tag | Sort-Object -Property { [version]$_ } @args }

    # Worktree
    function gwt { git worktree @args }
    function gwta { git worktree add @args }
    function gwtls { git worktree list @args }
    function gwtmv { git worktree move @args }
    function gwtrm { git worktree remove @args }

    # Cherry-pick
    function gcp { git cherry-pick @args }
    function gcpa { git cherry-pick --abort @args }
    function gcpc { git cherry-pick --continue @args }

    # Reflog
    function grf { git reflog @args }

    # Bisect
    function gbs { git bisect @args }
    function gbsb { git bisect bad @args }
    function gbsg { git bisect good @args }
    function gbsr { git bisect reset @args }
    function gbss { git bisect start @args }

    # Submodule
    function gsi { git submodule init @args }
    function gsu { git submodule update @args }

    # WIP (Work in Progress)
    function gwip {
        git add -A
        git rm (git ls-files --deleted) 2>$null
        git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"
    }

    function gunwip {
        $lastCommit = git log -1 --pretty=%B
        if ($lastCommit -match '--wip--') {
            git reset HEAD~1
        }
    }

    # Ignore/Unignore
    function gignore { git update-index --assume-unchanged @args }
    function gunignore { git update-index --no-assume-unchanged @args }
    function gignored { git ls-files -v | Select-String "^[[:lower:]]" }

    # Utilities
    function gcount { git shortlog --summary --numbered @args }
    function gfg { git ls-files | Select-String @args }

    Write-Host "Git aliases loaded (Oh My Zsh style)" -ForegroundColor Green
}
