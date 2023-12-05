# -- git clone --
# Recursively clone, then enter repo folder
gcl () {  # <uri> [<folder>] [<git clone arg>...]
  emulate -L zsh

  local uri=$1; shift

  local folder
  if [[ ! $1 || $1 =~ ^- ]] {
    folder=${${${uri:gs.:./}:t}%.git}
  } else {
    folder=$1; shift
  }

  git clone --recursive $@ $uri $folder \
  && cd $folder
}

# -- git clone (shallow) --
# Recursively clone, then enter repo folder
gcl1 () {  # <uri> [<folder>] [<git clone arg>...]
  gcl $@ --depth 1
}

# -- List tracked files --
gls () {  # [<branch> [<git ls-tree arg>...]]
  git ls-tree -r --name-only ${1:-$(git branch --show-current)} ${@[2,-1]}
}

# -- Push develop, master, and tags --
# bad name, sticking with it out of habit
hotfixed () {  # <master-branch-name>=master
  git checkout develop && git push
  git checkout ${1:-master} && git push
  git push --tags
  git checkout develop
}

alias gl="git pull --recurse-submodules"
alias gsb="git status -sb"
alias gco="git checkout --recurse-submodules"
alias gd="git diff --submodule=diff"
alias gc="git commit -v"
alias ga="git add"
alias gp="git push"
alias gm="git merge"
alias gapa="echoti clear && git add --patch"
alias gpsup="git push --set-upstream"
alias gfi="git flow init -d"

alias gson="git submodule update --init"
alias gsoff="git submodule deinit"

# -- git submodule foreach, and eval --
# You can use your functions and aliases
gse () {  # <cmd> [<cmd-arg>...]
  emulate -L zsh
  trap "cd ${(q-)PWD}" EXIT INT QUIT

  local folders=(${(f)"$(git submodule --quiet foreach pwd)"}) folder
  for folder ( $folders ) {
    print -rlu2 -- "-- Entering $folder to eval: $@"
    cd $folder
    eval "$@"
  }
}

# -- Completion Help Messages --
# Depends: .zshrc_help_complete, .zshrc_help_complete-as-prefix
if (( $+functions[.zshrc_help_complete] ))  .zshrc_help_complete gcl gcl1 gls hotfixed
if (( $+functions[.zshrc_help_complete-as-prefix] ))  .zshrc_help_complete-as-prefix gse
