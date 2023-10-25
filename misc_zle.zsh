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
.zle_replace-first () {
  local words=(${(z)BUFFER})
  zle .push-line
  BUFFER=" ${words[2,-1]}"
  CURSOR=0

  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N              .zle_replace-first
bindkey '^[^[[1;5A' .zle_replace-first  # esc, ctrl+up
bindkey   '^[[1;3H' .zle_replace-first  # esc, home

# -- Replace last word --
# Keys:
#   - esc, ctrl+down
#   - esc, end
.zle_replace-last () {
  local words=(${(z)BUFFER})
  zle .push-line
  BUFFER="${words[1,-2]} "
  CURSOR=$#BUFFER

  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N              .zle_replace-last
bindkey '^[^[[1;5B' .zle_replace-last  # esc, ctrl+down
bindkey   '^[[1;3F' .zle_replace-last  # esc, end

# -- Prepend doas --
# Key: esc, esc
.zle_prepend-doas () {
  BUFFER="doas $BUFFER"
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
  BUFFER="set -x; $obuffer; set +x"
  CURSOR=$#BUFFER

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
# Key: esc, u
bindkey '\eu' undo  # esc, u

# -- Edit current line in editor --
# Key: esc, e
autoload -Uz  edit-command-line
zle -N        edit-command-line
bindkey '\ee' edit-command-line  # esc, e

# -- Copy current line to clipboard --
# Key: esc, c
# TODO: test wayland
.zle_buffer-to-clipboard () {
  if [[ $XDG_SESSION_TYPE == x11 ]] {
    <<<$BUFFER xclip -sel clip
  } else {
    <<<$BUFFER wl-copy
  }
}
zle -N        .zle_buffer-to-clipboard
bindkey '\ec' .zle_buffer-to-clipboard  # esc, c

# -- Expand !! and !$ on space --
# Key: space
bindkey ' ' magic-space

# -- Avoid accidental stops --
# Key: (unsets) ctrl+s
setopt noflowcontrol
bindkey -r '^s'
