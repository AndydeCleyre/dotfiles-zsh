zmodload zsh/files
umask 007

# -- Make and enter a folder --
mkcd () {  # <folder>
  mkdir -p "$1" && cd "$1"
}

# -- Copy file to file.bak --
bak () {  # <file>...
  emulate -L zsh

  for 1 {
    cp -i $1 $1.bak
    ls -l $1 $1.bak
  }
}

# -- Open file with its default desktop program --
o () {  # <file>...
  for 1 { xdg-open $1 }
}

if (( $+functions[.zshrc_help_complete] ))  .zshrc_help_complete mkcd bak o
