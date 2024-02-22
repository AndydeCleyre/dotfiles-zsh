# -- Run input if single line, otherwise insert newline --
# Key: enter
# Assumes: setopt interactivecomments
# Credit: https://programming.dev/comment/2479198
.zle_accept-except-multiline () {
  if [[ $BUFFER != *$'\n'* ]] {
    zle .accept-line
    return
  } else {
    zle .self-insert-unmeta
    if [[ $BUFFER == *$'\n'*$'\n'* ]] {
      local hint="# Use alt+enter to submit this multiline input"
      if [[ $BUFFER != *${hint}* ]] {
        LBUFFER+=$hint
        zle .self-insert-unmeta
        if (( $+functions[_zsh_highlight] ))  _zsh_highlight
      }
    }
  }
}
zle -N .zle_accept-except-multiline
bindkey '^M' .zle_accept-except-multiline  # Enter

# -- Run input if multiline, otherwise insert newline --
# Key: alt+enter
# Credit: https://programming.dev/comment/2479198
.zle_accept_only_multiline () {
  if [[ $BUFFER == *$'\n'* ]] {
    zle .accept-line
  } else {
    zle .self-insert-unmeta
  }
}
zle -N .zle_accept_only_multiline
bindkey '^[^M' .zle_accept_only_multiline  # Enter
