if (( $+commands[tmux] )) {  # Without tmux, skip this file

if ! [[ $TMUX ]] { tmux new -A } else {  # Join or create a session in not in one already

# -- Activate copy mode and scroll up a page --
# Key: pgup
.zle_tmux-copy-mode-pgup () {
  tmux \
    copy-mode -u \; \
    send -X search-backward '^-- '  # jump to prompt prefix
}
zle -N          .zle_tmux-copy-mode-pgup
bindkey '^[[5~' .zle_tmux-copy-mode-pgup  # pgup

}

}
