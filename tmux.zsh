if (( $+commands[tmux] )) {  # Without tmux, skip this file

if [[ $TMUX ]] {

  # -- Activate copy mode and scroll up a page --
  # Key: pgup
  .zle_tmux-copy-mode-pgup () {
    tmux \
      copy-mode -u \; \
      send -X search-backward '^-- '  # jump to prompt prefix
  }
  zle -N          .zle_tmux-copy-mode-pgup
  bindkey '^[[5~' .zle_tmux-copy-mode-pgup  # pgup

} else {

  # -- Join or create a session --
  tmux new -A

}

# TODO: delete this, probably:
alias t="tmux new -A"

}
