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
.zle_replace-first () {
  local words=(${(z)BUFFER})
  print -S $BUFFER
  BUFFER=
  RBUFFER=" ${words[2,-1]}"

  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N              .zle_replace-first
bindkey '^[^[[1;5A' .zle_replace-first  # esc, ctrl+up
bindkey '^[[1;3H'   .zle_replace-first  # esc, home
bindkey '^[^?'      .zle_replace-first  # esc, backspace

# -- Replace last word --
# Keys:
#   - esc, ctrl+down
#   - esc, end
#   - esc, del
.zle_replace-last () {
  local words=(${(z)BUFFER})
  print -S $BUFFER
  BUFFER=
  LBUFFER="${words[1,-2]} "

  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N              .zle_replace-last
bindkey '^[^[[1;5B' .zle_replace-last  # esc, ctrl+down
bindkey '^[[1;3F'   .zle_replace-last  # esc, end
bindkey '^[^[[3~'   .zle_replace-last  # esc, del

# -- Prepend doas --
# Key: esc, esc
.zle_prepend-doas () {
  if (( $+commands[doas] )) {
    BUFFER="doas $BUFFER"
  } else {
    BUFFER="sudo $BUFFER"
  }
  CURSOR=$#BUFFER

  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N         .zle_prepend-doas
bindkey '\e\e' .zle_prepend-doas  # esc, esc

# -- `set -x` Sandwich --
# Key: esc, s
.zle_setx-sandwich () {
  local obuffer=$BUFFER
  zle .push-input
  LBUFFER="set -x; $obuffer; set +x"

  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N        .zle_setx-sandwich
bindkey '\es' .zle_setx-sandwich  # esc, s

# -- Expand aliases on the line --
# Key: esc, x
# Credit: https://unix.stackexchange.com/a/150737
.zle_expand-aliases () {
  functions[_expand-aliases]=$BUFFER
  BUFFER=${functions[_expand-aliases]#$'\t'}
  CURSOR=$#BUFFER

  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N        .zle_expand-aliases
bindkey '\ex' .zle_expand-aliases  # esc, x

# -- Undo line edit --
# Keys:
#   - esc, u
#   - esc, z
bindkey '\eu' undo  # esc, u
bindkey '\ez' undo  # esc, z

# -- Edit current line in editor --
# Key: esc, e
# A replacement for stock edit-command-line,
# to retrigger f-s-h
.zle_edit-command-line () {
  echoti rmkx
  () {
    <$TTY ${EDITOR:-vi} $1
    BUFFER=$(<$1)
    CURSOR=$#BUFFER
  } =(<<<"$BUFFER")
  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N        .zle_edit-command-line
bindkey '\ee' .zle_edit-command-line  # esc, e

# -- Copy current line to clipboard --
# Key: esc, c
# TODO: test wayland
# TODO: add PREBUFFER?
.zle_buffer-to-clipboard () {
  if [[ $XDG_SESSION_TYPE == x11 ]] {
    <<<$BUFFER xclip -sel clip
  } else {
    <<<$BUFFER wl-copy
  }
}
zle -N        .zle_buffer-to-clipboard
bindkey '\ec' .zle_buffer-to-clipboard  # esc, c

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
