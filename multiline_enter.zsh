# -- Latest command always at the top when set --
ZSHRC_CLEAR_BEFORE_ACCEPT=1

# -- Run input if single line, otherwise insert newline --
# Key: enter
# Optional: .zle::clear-screen-and-redraw (prompt_redraw.zsh)
# Credit: https://programming.dev/comment/2479198
.zle_accept-except-multiline () {
  if [[ $BUFFER != *$'\n'* ]] {
    if [[ $ZSHRC_CLEAR_BEFORE_ACCEPT ]] && [[ ! $PREBUFFER ]] {
      if (( $+functions[.zle::clear-screen-and-redraw] )) {
        zle .zle::clear-screen-and-redraw
      } else {
        zle .clear-screen
      }
    }
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
# Optional: .zle::clear-screen-and-redraw (prompt_redraw.zsh)
# Credit: https://programming.dev/comment/2479198
.zle_accept-only-multiline () {
  if [[ $BUFFER == *$'\n'* ]] {
    if [[ $ZSHRC_CLEAR_BEFORE_ACCEPT ]] && [[ ! $PREBUFFER ]] {
      zle -M 'DEBUG: NO PREBUFFER'
      if (( $+functions[.zle::clear-screen-and-redraw] )) {
        zle .zle::clear-screen-and-redraw
      } else {
        zle .clear-screen
      }
    }
    zle .accept-line
  } else {
    zle .self-insert-unmeta
  }
}
zle -N         .zle_accept-only-multiline
bindkey '^[^M' .zle_accept-only-multiline  # alt+enter
