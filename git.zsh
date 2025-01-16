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
alias gd="git diff --submodule=log"
alias gc="git commit -v"
alias ga="git add"
alias gp="git push"
alias gm="git merge"
alias gapa="echoti clear && git add --patch"
alias gpsup="git push --set-upstream"
alias gfi="git flow init -d"

# -- git submodule ... ACTIVATE! --
gson () {  # <submod-dir>...
  emulate -L zsh -o errreturn

  git submodule update --init --remote $@

  local groot submod relsubmod branch lines line
  groot=$(git rev-parse --show-toplevel)
  for submod ( $@ ) {
    relsubmod=${${submod:a}#$groot/}
    if ! { branch=$(git config -f "${groot}/.gitmodules" "submodule.$relsubmod.branch") } {
      lines=(${(f)"$(git -C $submod remote show origin)"})
      line=${(M)lines:#* HEAD branch: *}
      branch=${line#*: }
    }
    # git -C "$submod" config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    # git -C "$submod" switch "$branch"
    git -C $submod switch $branch
  }
}
alias gsoff="git submodule deinit"

# -- git submodule foreach, and eval --
# You can use your functions and aliases
gse () {  # <cmd> [<cmd-arg>...]
  emulate -L zsh -o localtraps
  trap "cd ${(q-)PWD}" EXIT INT QUIT

  local git_opts=()
  while [[ $1 == -* ]] { git_opts+=($1); shift }

  local origwd=$PWD
  local folders=(${(f)"$(git $git_opts submodule --quiet foreach pwd)"}) folder
  for folder ( $folders ) {
    print -rlPu2 -- '' "%B%F{white}-- %F{green}$%b%f $@ %B%F{yellow}:: %F{magenta}${${folder#$origwd/}/#~/~}%b%f"
    cd $folder
    eval "$@"
  }
}

# -- yadm-ify git func/alias --
# Basically, prepend GIT_DIR=(yadm repo)
# Key: esc, y
.zle_prepend-yadm () {
  local words=(${(z)BUFFER})
  print -S $BUFFER
  BUFFER=

  if [[ $words == gsb ]] {
    LBUFFER="GIT_DIR=${HOME}/.local/share/yadm/repo.git ${words} ."
  } elif [[ $words[1] == gse ]] {
    LBUFFER="${words[1]} --git-dir=${HOME}/.local/share/yadm/repo.git ${words[2,-1]}"
  } else {
    LBUFFER="GIT_DIR=${HOME}/.local/share/yadm/repo.git ${words}"
  }

  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N        .zle_prepend-yadm
bindkey '\ey' .zle_prepend-yadm  # esc, y

# -- Completion Help Messages --
# Depends: help.zsh (.zshrc_help_complete, .zshrc_help_complete-as-prefix)
if (( $+functions[.zshrc_help_complete]           ))  .zshrc_help_complete gcl gcl1 gls hotfixed
if (( $+functions[.zshrc_help_complete-as-prefix] ))  .zshrc_help_complete-as-prefix gse

# -- More Completions --
# Optional: help.zsh (_zshrc_help)
_gson () {
  if (( $+functions[_zshrc_help] ))  _zshrc_help ${0[2,-1]}
  words=(git submodule init --)
  (( CURRENT=$#words ))
  _normal -P
}
if (( $+functions[compdef] ))  compdef _gson gson
