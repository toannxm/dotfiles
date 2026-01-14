# Git aliases
# Common git shortcuts

# -------------------------------------------------------------------
# Help function
# -------------------------------------------------------------------
use ../common.nu *

export def "help git" [] {
    let title = "🚓 Git Helper Aliases & Functions"
    print $"($COLORS.blue)╭─────────────────────────────────────────╮($COLORS.reset)"
    print $"($COLORS.blue)│($COLORS.reset)  ($title)  ($COLORS.blue)│($COLORS.reset)"
    print $"($COLORS.blue)╰─────────────────────────────────────────╯($COLORS.reset)"
    print ""

    let bullet = $COLORS.yellow + "•" + $COLORS.reset

    print $"($COLORS.green)Core Shortcuts:($COLORS.reset)"
    print $"  gst      - git status -sb"
    print $"  gss      - git status --short"
    print $"  gci      - git commit"
    print $"  gcia     - git commit --amend --no-edit"
    print $"  gbr      - git branch"
    print $"  gco/gck  - git checkout"
    print $"  gdf      - git diff"
    print $"  gdc      - git diff --cached"
    print ""

    print $"($COLORS.green)Log & History:($COLORS.reset)"
    print $"  glg      - git log --oneline --decorate --graph"
    print $"  glga     - git log --oneline --decorate --graph --all"
    print $"  gls      - git log \(custom pretty format\)"
    print $"  glast    - git log -1 HEAD"
    print $"  gll      - git log \(relative time, committer\)"
    print ""

    print $"($COLORS.green)Diff Helpers:($COLORS.reset)"
    print $"  gdword   - git diff --word-diff"
    print $"  gdw      - git diff --word-diff=color"
    print ""

    print $"($COLORS.green)Staging & Reset:($COLORS.reset)"
    print $"  gunstage - git reset HEAD --"
    print $"  grsh     - git reset --hard HEAD"
    print $"  grs1     - git reset HEAD~1 --mixed"
    print ""

    print $"($COLORS.green)Rebase & Cherry-pick:($COLORS.reset)"
    print $"  grb      - git rebase"
    print $"  grbi     - git rebase -i"
    print $"  gcp      - git cherry-pick"
    print ""

    print $"($COLORS.green)Pull/Fetch/Push:($COLORS.reset)"
    print $"  gpll     - git pull -p --rebase"
    print $"  gpln     - git pull --no-rebase"
    print $"  gf       - git fetch -p"
    print $"  gfa      - git fetch --all --prune"
    print $"  gpsh     - git push origin HEAD"
    print $"  gpf      - git push --force-with-lease"
    print $"  gpft     - git push --follow-tags"
    print ""

    print $"($COLORS.green)Tags:($COLORS.reset)"
    print $"  gt       - git tag -l"
    print $"  gtn      - git tag -n"
    print ""

    print $"($COLORS.green)Remotes:($COLORS.reset)"
    print $"  gr       - git remote -v"
    print $"  gra      - git remote add"
    print $"  grr      - git remote remove"
    print ""

    print $"($COLORS.green)Stash:($COLORS.reset)"
    print $"  gsl      - git stash list"
    print $"  gssav    - git stash save"
    print $"  gsap     - git stash apply"
    print $"  gsp      - git stash pop"
    print $"  gsd      - git stash drop"
    print ""

    print $"($COLORS.green)Cleanups:($COLORS.reset)"
    print $"  gprune   - git remote prune origin"
    print $"  del_branch <name>   - Delete a specific branch"
    print $"  del_branch --all    - Delete all local branches \(except main/master/develop/current\)"
    print ""

    print $"($COLORS.green)Visual:($COLORS.reset)"
    print $"  gvisual  - gitk \(visual history\)"
    print ""

    print $"($COLORS.green)Grep & Blame:($COLORS.reset)"
    print $"  gg       - git grep -n --break --heading --line-number"
    print $"  gga      - git grep -n --break --heading --line-number -E"
    print $"  gbl      - git blame -w"
    print ""

    print $"($COLORS.green)Other Helpers:($COLORS.reset)"
    print $"  gignored - git ls-files -o -i --exclude-standard"
    print $"  gamend   - git commit --amend --no-edit"
    print $"  gac [msg] - Add all & commit \(default msg: update\)"
    print $"  gcb      - Show current branch name"
    print $"  gundo    - Undo last commit but keep changes staged"
    print ""

    print $"($COLORS.blue)Color Legend:($COLORS.reset)"
    print $"  ($COLORS.green)✓($COLORS.reset) Success / Safe"
    print $"  ($COLORS.yellow)•($COLORS.reset) Warning / Attention"
    print $"  ($COLORS.red)✗($COLORS.reset) Danger / Error"
    print $"  ($COLORS.blue)ℹ($COLORS.reset) Info / Utility"
    print $"  ($COLORS.gray)N/A($COLORS.reset) Not applicable"
    print ""
}

# Git branch completion helper
def get-git-branches [] {
    git branch --format='%(refname:short)' | lines | where { $in != "" }
}

# Git remote branch completion helper  
def get-git-remote-branches [] {
    git branch -r --format='%(refname:short)' | lines | where { $in != "" } | each { $in | str replace 'origin/' '' }
}

# Combined branch completion (local + remote)
def get-all-git-branches [] {
    let local = (get-git-branches)
    let remote = (get-git-remote-branches)
    $local | append $remote | uniq
}

# Core shortcuts
export alias g = git

export alias gst = g status -sb
export alias gss = g status --short
export alias gci = g commit
export alias gcia = g commit --amend --no-edit
export alias gbr = g branch
export alias gdf = g diff
export alias gdc = g diff --cached

# Git checkout with branch completion
export def gco [branch?: string@get-all-git-branches, ...args] {
    if ($branch | is-empty) {
        g checkout ...$args
    } else {
        g checkout $branch ...$args
    }
}

# Git checkout alias (same as gco)
export def gck [branch?: string@get-all-git-branches, ...args] {
    if ($branch | is-empty) {
        g checkout ...$args
    } else {
        g checkout $branch ...$args
    }
}

# Log / history views
export alias glg = g log --oneline --decorate --graph
export alias glga = g log --oneline --decorate --graph --all
export alias gls = g log --pretty=format:'%C(yellow)%h %C(cyan)%ad %C(red)%d %C(reset)%s %C(blue)[%cn]' --decorate --date=short
export alias glast = g log -1 HEAD
export alias gll = g log --pretty=format:'%C(auto)%h %C(blue)%an %C(green)%cr %C(yellow)%s %C(red)%d' --decorate --graph
# Diff helpers
export alias gdword = g diff --word-diff
export alias gdw = g diff --word-diff=color

# Staging / resets
export alias gunstage = g reset HEAD --
export alias grsh = g reset --hard HEAD
export alias grs1 = g reset HEAD~1 --mixed

# Rebasing / cherry pick
export alias grb = g rebase
export alias grbi = g rebase -i
export alias gcp = g cherry-pick

# Pull / fetch / push
export alias gpll = g pull -p --rebase
export alias gpln = g pull --no-rebase
export alias gf = g fetch -p
export alias gfa = g fetch --all --prune
export alias gpsh = g push origin HEAD
export alias gpf = g push --force-with-lease
export alias gpft = g push --follow-tags
# Tags
export alias gt = g tag -l
export alias gtn = g tag -n

# Remotes
export alias gr = g remote -v
export alias gra = g remote add
export alias grr = g remote remove

# Stash
export alias gsl = g stash list
export alias gssav = g stash save
export alias gsap = g stash apply
export alias gsp = g stash pop
export alias gsd = g stash drop

# Cleanups
export alias gprune = g remote prune origin
# For clean-branches, use a Nushell def for more logic

# Visual
export alias gvisual = gitk

# Grep helpers
export alias gg = git grep -n --break --heading --line-number
export alias gga = git grep -n --break --heading --line-number -E

# Blame
export alias gbl = git blame -w

# Show ignored files
export alias gignored = git ls-files -o -i --exclude-standard

# Amend latest commit
export alias gamend = git commit --amend --no-edit

# Quick add & commit
def gac [msg: string = "update"] { git add -A; git commit -m $msg }

# Show current branch name only
export alias gcb = git rev-parse --abbrev-ref HEAD

# Undo last commit but keep changes staged
export alias gundo = git reset --soft HEAD~1

# Delete git branch(es) with confirmation
# Usage: del_branch <branch_name>  - Delete specific branch
#        del_branch --all          - Delete all local branches except current and protected ones
export def del_branch [
    branch?: string  # Branch name to delete, or use --all flag
    --all            # Delete all local branches except current and protected ones
] {
    if $all {
        # Get current branch
        let current_branch = (git rev-parse --abbrev-ref HEAD | str trim)
        
        # Protected branches that should never be deleted
        let protected = ["main", "master", "develop", "development"]
        
        # Get all local branches except current and protected
        let branches_to_delete = (
            git branch --format='%(refname:short)' 
            | lines 
            | where $it != $current_branch 
            | where $it not-in $protected
        )
        
        if ($branches_to_delete | is-empty) {
            print "ℹ️  No branches to delete"
            return
        }
        
        print $"⚠️  About to delete ($branches_to_delete | length) branches:"
        print ($branches_to_delete | each { |b| $"  - ($b)" } | str join "\n")
        print $"\nCurrent branch '($current_branch)' and protected branches will be kept."
        
        let confirm = (input "Type 'yes' to confirm: ")
        if $confirm == "yes" {
            for branch in $branches_to_delete {
                git branch -D $branch
                print $"✓ Deleted branch: ($branch)"
            }
            print $"\n✓ Deleted ($branches_to_delete | length) branches"
        } else {
            print "❌ Branch deletion cancelled"
        }
    } else if ($branch | is-empty) {
        print "❌ Please provide a branch name or use --all flag"
        print "Usage: del_branch <branch_name> or del_branch --all"
    } else {
        print $"⚠️  About to delete branch: ($branch)"
        let confirm = (input "Type 'yes' to confirm: ")
        if $confirm == "yes" {
            git branch -D $branch
            print $"✓ Deleted branch: ($branch)"
        } else {
            print "❌ Branch deletion cancelled"
        }
    }
}
