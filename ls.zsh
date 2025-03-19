if (( $+commands[eza] )) {
  export EZA_ICON_SPACING=2
  alias ls="eza --binary --octal-permissions --no-permissions --git --icons=always"
  alias recent="eza --binary --octal-permissions --no-permissions --git -snew --icons=always"
} else {
  alias ls="=ls --color=auto"
  alias recent="=ls -rt"
}

alias lsl="ls -la"

# -- tree --
# Depends: tree, eza, or broot
# broot backend ignores the depth option
# -L <depth> -- this many levels
# -d         -- only show folders
tree () {  # [-L <depth>] [-d] [<arg>...]
  emulate -L zsh
  rehash

  local cmd depth dirsonly
  if (( $+commands[broot] )) {
    while [[ $1 =~ '^-[Ld]$' ]] {
      if [[ $1 == -L ]]  shift 2
      if [[ $1 == -d ]] { dirsonly=-f; shift }
    }
    cmd=(broot -S $dirsonly -c ' pt' --height $((LINES-2)))
  } elif (( $+commands[eza] )) {
    while [[ $1 =~ '^-[Ld]$' ]] {
      if [[ $1 == -L ]] { depth=(-L $2); shift 2 }
      if [[ $1 == -d ]] { dirsonly=-D; shift }
    }
    cmd=(eza -T -l --git --no-time --no-user --no-filesize --no-permissions $depth $dirsonly)
  } elif (( $+commands[tree] )) {
    cmd=(=tree -C)
  } else {
    print -rlu2 -- "tree, eza, or broot required"
    return 1
  }
  $cmd $@
}

ncdu () {
  =ncdu -t ${${$(nproc 2>/dev/null):-$(sysctl -n hw.logicalcpu 2>/dev/null)}:-4} -x -e --color dark-bg $@
}

if (( $+functions[.zshrc_help_complete] ))  .zshrc_help_complete tree
