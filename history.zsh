HISTFILE=${XDG_STATE_HOME:-~/.local/state}/zsh/history
mkdir -p ${HISTFILE:h}
HISTSIZE=10000
SAVEHIST=10000
setopt \
  hist_ignore_all_dups \
  hist_ignore_space \
  hist_verify \
  share_history

# -- Modification of history-search-end builtin --
# Keys: {up,down}
# This re-triggers f-s-h.
.zle_hist () {
  integer cursor=$CURSOR mark=$MARK
  if [[ $LASTWIDGET == .zle_hist-* ]] {
    CURSOR=$MARK
  } else {
    MARK=$CURSOR
  }
  if { zle .history-beginning-search-${WIDGET##*-}ward } {
    zle .end-of-line
  } else {
    CURSOR=$cursor
    MARK=$mark
    return 1
  }
  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
() {
  emulate -L zsh
  local widget keyseq
  for widget ( back for )  zle -N .zle_hist-${widget} .zle_hist
  for keyseq ( '^[OA' '^[[A' )  bindkey $keyseq .zle_hist-back  # up
  for keyseq ( '^[OB' '^[[B' )  bindkey $keyseq .zle_hist-for   # down
}

## -- Simple History --
## Keys: {up,down}
## This doesn't bother to re-trigger fast-syntax-highlighting,
## and is kept for reference.
#() {
#  emulate -L zsh
#  autoload -Uz history-search-end
#  local widget keyseq
#  for widget ( back for )  zle -N history-beginning-search-${widget}ward-end history-search-end
#  for keyseq ( '^[OA' '^[[A' )  bindkey $keyseq history-beginning-search-backward-end  # up
#  for keyseq ( '^[OB' '^[[B' )  bindkey $keyseq history-beginning-search-forward-end   # down
#}
