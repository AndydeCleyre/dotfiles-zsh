setopt interactivecomments

WORDCHARS=${WORDCHARS//[-=\/]}

# -- Kill word left --
# Key: ctrl+backspace
bindkey '^H' backward-kill-word  # ctrl+backspace

# -- Kill word right --
# Key: ctrl+delete
bindkey '^[[3;5~' kill-word  # ctrl+delete

# -- Replace first word --
# Keys:
#   - esc, ctrl+up
#   - esc, home
#   - esc, backspace
.zle::replace-first () {
  local words=(${(z)BUFFER})
  print -S $BUFFER
  BUFFER=
  RBUFFER=" ${words[2,-1]}"

  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N              .zle::replace-first
# bindkey '^[^[[1;5A' .zle::replace-first  # esc, ctrl+up
# bindkey '^[[1;3H'   .zle::replace-first  # esc, home
bindkey '^[^?'      .zle::replace-first  # esc, backspace

# -- Replace last word --
# Keys:
#   - esc, ctrl+down
#   - esc, end
#   - esc, del
.zle::replace-last () {
  local words=(${(z)BUFFER})
  print -S $BUFFER
  BUFFER=
  LBUFFER="${words[1,-2]} "

  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N              .zle::replace-last
# bindkey '^[^[[1;5B' .zle::replace-last  # esc, ctrl+down
# bindkey '^[[1;3F'   .zle::replace-last  # esc, end
bindkey '^[^[[3~'   .zle::replace-last  # esc, del

# -- Prepend doas --
# Key: esc, esc
.zle::prepend-doas () {
  if (( $+commands[doas] )) {
    BUFFER="doas $BUFFER"
  } else {
    BUFFER="sudo $BUFFER"
  }
  CURSOR=$#BUFFER

  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N         .zle::prepend-doas
bindkey '\e\e' .zle::prepend-doas  # esc, esc

# -- `set -x` Sandwich --
# Key: esc, s
.zle::setx-sandwich () {
  local obuffer=$BUFFER
  zle .push-input
  LBUFFER="set -x; $obuffer; set +x"

  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N        .zle::setx-sandwich
bindkey '\es' .zle::setx-sandwich  # esc, s

# -- Array of output lines from current command --
# Key: esc, l
.zle::output-lines-array () {
  local obuffer=$BUFFER
  zle .push-input
  LBUFFER='for line ( ${(f)"$('$obuffer')"} ) {'$'\n''  '
  RBUFFER=' $line'$'\n''}'
  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N        .zle::output-lines-array
bindkey '\el' .zle::output-lines-array  # esc, l

# -- Expand aliases on the line --
# Key: esc, x
# Credit: https://unix.stackexchange.com/a/150737
.zle::expand-aliases () {
  functions[_expand-aliases]=$BUFFER
  BUFFER=${functions[_expand-aliases]#$'\t'}
  CURSOR=$#BUFFER

  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N        .zle::expand-aliases
bindkey '\ex' .zle::expand-aliases  # esc, x

# -- Undo line edit --
# Key: esc, u
bindkey '\eu' undo  # esc, u

# -- Edit current line in editor --
# Key: esc, e
# A replacement for stock edit-command-line,
# to retrigger f-s-h
.zle::edit-command-line () {
  echoti rmkx
  () {
    <$TTY ${EDITOR:-vi} $1
    BUFFER=$(<$1)
    CURSOR=$#BUFFER
  } =(<<<"$BUFFER")
  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N        .zle::edit-command-line
bindkey '\ee' .zle::edit-command-line  # esc, e

# -- Copy current line to clipboard --
# Key: esc, c
# TODO: test wayland
# TODO: add PREBUFFER?
.zle::buffer-to-clipboard () {
  if [[ $XDG_SESSION_TYPE == x11 ]] {
    <<<$BUFFER xclip -sel clip
  } else {
    <<<$BUFFER wl-copy
  }
}
zle -N        .zle::buffer-to-clipboard
bindkey '\ec' .zle::buffer-to-clipboard  # esc, c

# -- Avoid accidental stops --
# Key: (unsets) ctrl+s
setopt noflowcontrol
bindkey -r '^s'

# -- Fix spelling --
# Key: esc, f
bindkey '\ef' spell-word  # esc, f

# -- Evaluate prefixed aliases --
alias doas="=doas "
alias sudo="=sudo "

# -- Copy previous word on line --
# Key: esc, space
bindkey '\e ' copy-prev-shell-word

# -- Don't color bg for pasted text --
zle_highlight=(paste:none)

# TODO: check line spelling (hunspell -l?)

# -- Replace home with tilde in line --
.zle::replace-homepaths-with-tilde () {
  BUFFER=${BUFFER//~/\~}
}
zle -N        .zle::replace-homepaths-with-tilde
bindkey '^[~' .zle::replace-homepaths-with-tilde  # esc, tilde

# -- Replace home with $HOME in line --
.zle::replace-homepaths-with-homevar () {
  BUFFER=${BUFFER//~/'$HOME'}
}
zle -N        .zle::replace-homepaths-with-homevar
bindkey '^[$' .zle::replace-homepaths-with-homevar  # esc, dollar-sign
