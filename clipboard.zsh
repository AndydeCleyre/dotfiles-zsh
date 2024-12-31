# -- Copy stdin or file content to clipboard --
# TODO: test wayland
c () {  # [<file>]
  if [[ $XDG_SESSION_TYPE == x11 ]] {
    xclip -sel clip $@
  } else {
    <$@ wl-copy
  }
}

# -- Paste clipboard to stdout --
# TODO: test wayland
p () {  # (no arguments)
  if [[ $XDG_SESSION_TYPE == x11 ]] {
    xclip -sel clip -o
  } else {
    wl-paste
  }
}

# -- Completion Help Messages --
# Depends: .zshrc_help_complete (help.zsh)
if (( $+functions[.zshrc_help_complete] ))  .zshrc_help_complete c p
