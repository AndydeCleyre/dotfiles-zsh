zmodload -mF zsh/files 'b:(mkdir|ln|mv|rmdir|rm)'
umask 007

# -- Make and enter a folder --
mkcd () {  # <folder>
  mkdir -p "$1" && cd "$1"
}

# -- Copy file to file.bak --
bak () {  # <file>...
  emulate -L zsh

  local dest
  for 1 {
    dest=$1.bak
    while [[ -e $dest ]]  dest=$dest.bak
    cp -ri $1 $dest
    ls -l $1 $dest
  }
}

# -- Open file with its default desktop program --
o () {  # <file>...
  for 1 { xdg-open $1 }
}

if (( $+functions[.zshrc_help_complete] ))  .zshrc_help_complete mkcd bak o
