# -- Better Screen Clearing --
# Clear line and redraw prompt, restore line at next prompt
# Key: ctrl+l
# Optional: .zle::clear-screen-and-redraw (prompt_redraw.zsh)
.zle::push-line-and-clear () {
  zle .push-input
  if (( $+functions[.zle::clear-screen-and-redraw] )) {
    zle .zle::clear-screen-and-redraw
  } else {
    zle .clear-screen
  }
}
zle -N       .zle::push-line-and-clear
bindkey '^L' .zle::push-line-and-clear  # ctrl+l

# -- Folder Navigation: Home --
# Key: ctrl+~
# Optional: .zle::redraw-prompt (prompt_redraw.zsh)
.zle::cd-home () {
  cd
  if (( $+functions[.zle::redraw-prompt] ))  zle .zle::redraw-prompt
}
zle -N       .zle::cd-home
bindkey '^^' .zle::cd-home  # ctrl+~

# -- Folder Navigation: Down --
# Key: alt+down
# Superseded in broot.zsh
.zle::cd-down () {
  zle .push-input
  LBUFFER="cd "
  zle .menu-expand-or-complete
  # zle .expand-or-complete
}
zle -N            .zle::cd-down
bindkey '^[[1;3B' .zle::cd-down  # alt+down

# ------------------------------------
# Folder Navigation: Up, Back, Forward
# ------------------------------------
# Keys: alt+{up,left,right}
# Optional: .zle::redraw-prompt (prompt_redraw.zsh)
# Credit: Roman Perepelitsa
# Original: https://github.com/romkatv/zsh4humans/blob/v2/fn/-z4h-cd-rotate

setopt autopushd pushdignoredups
DIRSTACKSIZE=12

.zle::cd-up () {
  cd ..
  if (( $+functions[.zle::redraw-prompt] ))  zle .zle::redraw-prompt
}
zle -N            .zle::cd-up
bindkey '^[[1;3A' .zle::cd-up  # alt+up

.zle::cd-rotate () {
  while (( $#dirstack )) && ! { pushd -q $1 &>/dev/null } { popd -q $1 }
  if (( $#dirstack )) {
    if (( $+functions[.zle::redraw-prompt] ))  zle .zle::redraw-prompt
  }
}

.zle::cd-back () { .zle::cd-rotate +1 }
zle -N            .zle::cd-back
bindkey '^[[1;3D' .zle::cd-back  # alt+left

.zle::cd-forward () { .zle::cd-rotate -0 }
zle -N            .zle::cd-forward
bindkey '^[[1;3C' .zle::cd-forward  # alt+right
