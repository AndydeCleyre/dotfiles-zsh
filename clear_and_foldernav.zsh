# -- Refresh prompt, rerunning any hooks --
# Credit: romkatv/z4h
.zle_redraw-prompt () {
  for 1 ( chpwd $chpwd_functions precmd $precmd_functions ) {
    if (( $+functions[$1] ))  $1 &>/dev/null
  }
  zle .reset-prompt
  zle -R
}
zle -N .zle_redraw-prompt

# -- Better Screen Clearing --
# Clear line and redraw prompt, restore line at next prompt
# Key: ctrl+l
# Optional: .zle_redraw-prompt
.zle_push-line-and-clear () {
  zle .push-input
  zle .clear-screen
  if (( $+functions[.zle_redraw-prompt] ))  zle .zle_redraw-prompt
}
zle -N       .zle_push-line-and-clear
bindkey '^L' .zle_push-line-and-clear  # ctrl+l

# -- Folder Navigation: Down --
# Key: alt+down
# Superseded in ~/.config/zsh/broot.zsh
.zle_cd-down () {
  zle .push-input
  BUFFER="cd "
  CURSOR=$#BUFFER
  zle .menu-expand-or-complete
}
zle -N            .zle_cd-down
bindkey '^[[1;3B' .zle_cd-down  # alt+down

# ------------------------------------
# Folder Navigation: Up, Back, Forward
# ------------------------------------
# Keys: alt+{up,left,right}
# Optional: .zle_redraw-prompt
# Credit: romkatv/z4h
setopt autopushd pushdignoredups
DIRSTACKSIZE=12

.zle_cd-up () {
  cd ..
  if (( $+functions[.zle_redraw-prompt] ))  zle .zle_redraw-prompt
}
zle -N            .zle_cd-up
bindkey '^[[1;3A' .zle_cd-up  # alt+up

.zle_cd-rotate () {
  while (( $#dirstack )) && ! { pushd -q $1 &>/dev/null } { popd -q $1 }
  if (( $#dirstack )) {
    if (( $+functions[.zle_redraw-prompt] ))  zle .zle_redraw-prompt
  }
}

.zle_cd-back () { .zle_cd-rotate +1 }
zle -N            .zle_cd-back
bindkey '^[[1;3D' .zle_cd-back  # alt+left

.zle_cd-forward () { .zle_cd-rotate -0 }
zle -N            .zle_cd-forward
bindkey '^[[1;3C' .zle_cd-forward  # alt+right
