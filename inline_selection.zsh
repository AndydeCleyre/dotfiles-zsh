# -- Select all --
# Key: ctrl+a
.zle_select-all () {
  (( CURSOR=0 ))
  (( MARK=$#BUFFER ))
  (( REGION_ACTIVE=1 ))
  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N       .zle_select-all
bindkey '^A' .zle_select-all  # ctrl+a

# -- Surround selection with single quote, or type single quote --
# Key: '
.zle_squote-selection-or-squote () {
  if (( REGION_ACTIVE )) {
    zle .quote-region
  } else {
    zle .self-insert \'
  }
}
zle -N      .zle_squote-selection-or-squote
bindkey "'" .zle_squote-selection-or-squote  # '

# -- Surround selection with an open-close pair ({}, (), etc.), or type the opener --
# Keys:
#   - {
#   - [
#   - (
#   - "
.zshrc_def-surround-selection-or-type-opener () {  # <opener> <closer> <name>
  eval "
    .zle_$3-selection-or-$3 () {
      if (( REGION_ACTIVE )) {
        local start_end=(\$CURSOR \$MARK)
        start_end=(\${(n)start_end})

        local left=\${BUFFER[1,start_end[1]]}
        local right=\${BUFFER[start_end[-1]+1,#BUFFER]}
        local middle=${(q-)1}\${BUFFER[start_end[1]+1,start_end[-1]]}${(q-)2}

        BUFFER=\${left}\${middle}\${right}

        (( REGION_ACTIVE=0 ))
        (( CURSOR=\$#left+\$#middle ))

        if (( \$+functions[_zsh_highlight] ))  _zsh_highlight
      } else {
        zle .self-insert ${(q-)1}
      }
    }
    zle -N           .zle_$3-selection-or-$3
    bindkey ${(q-)1} .zle_$3-selection-or-$3
  "
}
.zshrc_def-surround-selection-or-type-opener '{' '}' brace
.zshrc_def-surround-selection-or-type-opener '[' ']' bracket
.zshrc_def-surround-selection-or-type-opener '(' ')' paren
.zshrc_def-surround-selection-or-type-opener '"' '"' dquote
unfunction .zshrc_def-surround-selection-or-type-opener

# -- Delete selection and type character --
# Keys: most characters
# Warning: this might make typing noticeably slower
.zshrc_def-del-selected-and-type-char () {  # <char> [<name>]
  if [[ ! $2 ]]  2=$1
  eval "
    .zle_del-selected-and-type-$2 () {
      if (( REGION_ACTIVE ))  zle .kill-region
      zle .self-insert ${(q-)1}
      if (( \$+functions[_zsh_highlight] ))  _zsh_highlight
    }
    zle -N           .zle_del-selected-and-type-$2
    bindkey -- ${(q-)1} .zle_del-selected-and-type-$2
  "
}
() {
  emulate -L zsh
  local char
  for char (
    q w e r t y u i o p a s d f g h j k l z x c v b n m
    Q W E R T Y U I O P A S D F G H J K L Z X C V B N M
    1 2 3 4 5 6 7 8 9 0 , : / . + _ % @ ! = ^ $ -
    \~ \#
  )  .zshrc_def-del-selected-and-type-char $char
  .zshrc_def-del-selected-and-type-char \; semicolon
  .zshrc_def-del-selected-and-type-char \< lt
  .zshrc_def-del-selected-and-type-char \> gt
  .zshrc_def-del-selected-and-type-char \? question
  .zshrc_def-del-selected-and-type-char \` backtick
  .zshrc_def-del-selected-and-type-char \& amp
  .zshrc_def-del-selected-and-type-char \* star
  .zshrc_def-del-selected-and-type-char \\ backslash
  .zshrc_def-del-selected-and-type-char \| pipe
  .zshrc_def-del-selected-and-type-char \) paren
  .zshrc_def-del-selected-and-type-char \} brace
  .zshrc_def-del-selected-and-type-char \] bracket
  .zshrc_def-del-selected-and-type-char ' ' space
}
unfunction .zshrc_def-del-selected-and-type-char

# --------------------------------
# -- Move cursor and (de)select --
# --------------------------------
# Credit: https://stackoverflow.com/a/30899296

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

# -- Backspace or delete selection or undo completion --
# Key: backspace

# -- Delete or delete selection --
# Key: del

.zshrc_def-select-and () {  # <action> <wrapped-zle> <keyseq>...
  eval "
    .zle_select-and-$1 () {
      if ! (( REGION_ACTIVE ))  zle .set-mark-command
      zle $2
      if (( \$+functions[_zsh_highlight] ))  _zsh_highlight
    }
    zle -N                                         .zle_select-and-$1
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
    zle -N                                         .zle_deselect-and-$1
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
    zle -N                                         .zle_del-selected-or-$1
    for keyseq ( ${(q)@[3,-1]} )  bindkey \$keyseq .zle_del-selected-or-$1
  "
}

.zle_backspace-or-undo () {
  if [[ $LASTWIDGET == *complet* ]] {
    zle .undo
  } else {
    zle .backward-delete-char
  }
}
zle -N .zle_backspace-or-undo


() {
  emulate -L zsh

  local keyseq

  .zshrc_def-deselect-and left       .backward-char         '^[[D'                    # left
  .zshrc_def-deselect-and right      .forward-char          '^[[C'                    # right
  .zshrc_def-deselect-and left-word  .backward-word         '^[[1;5D' '^[[5~'         # {ctrl+left,pgup}
  .zshrc_def-deselect-and right-word .forward-word          '^[[1;5C' '^[[6~'         # {ctrl+right,pgdown}
  .zshrc_def-deselect-and home       .beginning-of-line     '^[[1;5A' '^[[H' '^[[1~'  # home
  .zshrc_def-deselect-and end        .end-of-line           '^[[1;5B' '^[[F' '^[[4~'  # end

  .zshrc_def-select-and left         .backward-char         '^[[1;2D'                 # shift+left
  .zshrc_def-select-and right        .forward-char          '^[[1;2C'                 # shift+right
  .zshrc_def-select-and left-word    .backward-word         '^[[1;6D' '^[[5;2~'       # {ctrl+shift+left,shift+pgup}
  .zshrc_def-select-and right-word   .forward-word          '^[[1;6C' '^[[6;2~'       # {ctrl+shift+right,shift+pgdown}
  .zshrc_def-select-and home         .beginning-of-line     '^[[1;2H' '^[[1;6A'       # {shift+home,ctrl+shift+up}
  .zshrc_def-select-and end          .end-of-line           '^[[1;2F' '^[[1;6B'       # {shift+end,ctrl+shift+down}

  .zshrc_def-del-selected-or bksp    .zle_backspace-or-undo '^?'                      # backspace
  .zshrc_def-del-selected-or del     .delete-char           '^[[3~' "^[3'5~" '\e[3~'  # delete
}
unfunction .zshrc_def-select-and .zshrc_def-deselect-and .zshrc_def-del-selected-or
