# -- Run input if single line, otherwise insert newline --
# Key: enter
# Credit: https://programming.dev/comment/2479198
.zle_accept-except-multiline () {
  if [[ $BUFFER != *$'\n'* ]] {
    zle .accept-line
    return
  } else {
    zle .self-insert-unmeta
    zle -M 'Use alt+enter to submit this multiline input'
  }
}
zle -N       .zle_accept-except-multiline
bindkey '^M' .zle_accept-except-multiline  # enter

# -- Run input if multiline, otherwise insert newline --
# Key: alt+enter
# Credit: https://programming.dev/comment/2479198
.zle_accept-only-multiline () {
  if [[ $BUFFER == *$'\n'* ]] {
    zle .accept-line
  } else {
    zle .self-insert-unmeta
  }
}
zle -N         .zle_accept-only-multiline
bindkey '^[^M' .zle_accept-only-multiline  # alt+enter
