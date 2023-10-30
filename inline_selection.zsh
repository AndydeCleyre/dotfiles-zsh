# Credit: https://stackoverflow.com/a/30899296

# -- Select all --
# Key: ctrl+a
.zle_select-all () {
  (( CURSOR=0 ))
  (( MARK=$#BUFFER ))
  (( REGION_ACTIVE=1 ))
  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N .zle_select-all
bindkey '^A' .zle_select-all  # ctrl+a

.zshrc_def-select-and () {  # <action> <wrapped-zle> <keyseq>...

  eval "
    .zle_select-and-$1 () {
      if ! (( REGION_ACTIVE ))  zle .set-mark-command
      zle $2
      if (( \$+functions[_zsh_highlight] ))  _zsh_highlight
    }
    zle -N .zle_select-and-$1
    for keyseq ( ${(q)@[3,-1]} )  bindkey \$keyseq .zle_select-and-$1
  "

}

.zshrc_def-deselect-and () {  # <action> <wrapped-zle> <keyseq>...

  eval "
    .zle_deselect-and-$1 () {
      (( REGION_ACTIVE=0 ))
      zle $2
      if (( \$+functions[_zsh_highlight] ))  _zsh_highlight
    }
    zle -N .zle_deselect-and-$1
    for keyseq ( ${(q)@[3,-1]} )  bindkey \$keyseq .zle_deselect-and-$1
  "

}

.zshrc_def-del-selected-or () {  # <action> <wrapped-zle> <keyseq>...

  eval "
    .zle_del-selected-or-$1 () {
      if (( REGION_ACTIVE )) {
        zle .kill-region
      } else {
        zle $2
      }
      if (( \$+functions[_zsh_highlight] ))  _zsh_highlight
    }
    zle -N .zle_del-selected-or-$1
    for keyseq ( ${(q)@[3,-1]} )  bindkey \$keyseq .zle_del-selected-or-$1
  "

}

() {
  emulate -L zsh

  local keyseq

  .zshrc_def-deselect-and left       .backward-char '^[[D'                        # left
  .zshrc_def-deselect-and right      .forward-char '^[[C'                         # right
  .zshrc_def-deselect-and left-word  .backward-word '^[[1;5D' '^[[5~'             # {ctrl+left,pgup}
  .zshrc_def-deselect-and right-word .forward-word '^[[1;5C' '^[[6~'              # {ctrl+right,pgdown}
  .zshrc_def-deselect-and home       .beginning-of-line '^[[1;5A' '^[[H' '^[[1~'  # home
  .zshrc_def-deselect-and end        .end-of-line '^[[1;5B' '^[[F' '^[[4~'        # end

  .zshrc_def-select-and left       .backward-char '^[[1;2D'                # shift+left
  .zshrc_def-select-and right      .forward-char '^[[1;2C'                 # shift+right
  .zshrc_def-select-and left-word  .backward-word '^[[1;6D' '^[[5;2~'      # {ctrl+shift+left,shift+pgup}
  .zshrc_def-select-and right-word .forward-word '^[[1;6C' '^[[6;2~'       # {ctrl+shift+right,shift+pgdown}
  .zshrc_def-select-and home       .beginning-of-line '^[[1;2H' '^[[1;6A'  # {shift+home,ctrl+shift+up}
  .zshrc_def-select-and end        .end-of-line '^[[1;2F' '^[[1;6B'        # {shift+end,ctrl+shift+down}

  .zshrc_def-del-selected-or bksp .backward-delete-char '^?'             # backspace
  .zshrc_def-del-selected-or del  .delete-char '^[[3~' "^[3'5~" '\e[3~'  # delete

}

unfunction .zshrc_def-select-and .zshrc_def-deselect-and .zshrc_def-del-selected-or

# -- Cursor left and deselect --
# Key: left

# -- Cursor right and deselect --
# Key: right

# -- Cursor left-word and deselect --
# Keys:
#   - ctrl+left
#   - pgup (Superseded in tmux.zsh)

# -- Cursor right-word and deselect --
# Keys:
#   - ctrl+right
#   - pgdown

# -- Cursor home and deselect --
# Key: home

# -- Cursor end and deselect --
# Key: end

# -- Select left --
# Key: shift+left

# -- Select right --
# Key: shift+right

# -- Select left-word --
# Keys:
#   - ctrl+shift+left
#   - shift+pgup

# -- Select right-word --
# Keys:
#   - ctrl+shift+right
#   - shift+pgdown

# -- Select to home --
# Keys:
#   - shift+home
#   - ctrl+shift+up

# -- Select to end --
# Keys:
#   - shift+end
#   - ctrl+shift+down

# -- Backspace or delete selection --
# Key: backspace

# -- Delete or delete selection --
# Key: del
