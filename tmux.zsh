if (( $+commands[tmux] )) {  # Without tmux, skip this file

if ! [[ $TMUX ]] { tmux new -A } else {  # Join or create a session if not in one already

# -- Activate copy mode and scroll up a page --
# Key: pgup
.zle_tmux-copy-mode-pgup () {
  tmux \
    copy-mode -u \; \
    send -X search-backward '^-- \$'  # jump to prompt prefix
}
zle -N          .zle_tmux-copy-mode-pgup
bindkey '^[[5~' .zle_tmux-copy-mode-pgup  # pgup

# -- Activate copy mode and select the last output block --
# Key: shift+pgup
.zle_tmux-copy-mode-last-output () {
  tmux \
    copy-mode \; \
    send -X previous-paragraph \; \
    send -X begin-selection \; \
    send -X search-backward '^-- ' \; \
    send -X cursor-down \; \
    send -X stop-selection
}
zle -N            .zle_tmux-copy-mode-last-output
bindkey '^[[5;2~' .zle_tmux-copy-mode-last-output  # shift+pgup

}

}
