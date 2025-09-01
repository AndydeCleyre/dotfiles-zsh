# -- Refresh prompt, rerunning any hooks --
# Credit: Roman Perepelitsa
# Original: https://github.com/romkatv/zsh4humans/blob/v2/fn/-z4h-redraw-prompt
.zle_redraw-prompt () {
  for 1 ( chpwd $chpwd_functions precmd $precmd_functions ) {
    if (( $+functions[$1] ))  $1 &>/dev/null
  }
  zle .reset-prompt
  zle -R
}
zle -N .zle_redraw-prompt

# -- Remove a leading newline from the prompt, returning 0 if there was one --
.zshrc_prompt-remove-leading-newline () {
  emulate -L zsh
  local found semantic_start=$'%{\C-[]133;P;k=i\C-G%}'
  if [[ $PS1 == ($semantic_start|)$'\n'* ]] {
    found=1
    PS1=${PS1/$'\n'}
  }
  if [[ ! $found ]]  return 2
}

# -- Prepend a newline to the prompt, preserving the semantic prompt start code if present --
.zshrc_prompt-prepend-newline () {
  emulate -L zsh
  local semantic_start=$'%{\C-[]133;P;k=i\C-G%}'
  if [[ $PS1 == ${semantic_start}* ]] {
    PS1=${PS1/${semantic_start}/${semantic_start}$'\n'}
  } else {
    PS1=$'\n'${PS1}
  }
}

# -- Better Screen Clearing --
# Clear line and redraw prompt, restore line at next prompt
# Key: ctrl+l
# Optional: .zle_redraw-prompt, .zshrc_prompt-{remove-leading,prepend}-newline
.zle_push-line-and-clear () {
  ZSHRC_PROMPT_STASHED_NEWLINE=
  if (( $+functions[.zshrc_prompt-remove-leading-newline] )) {
    if { .zshrc_prompt-remove-leading-newline }  ZSHRC_PROMPT_STASHED_NEWLINE=1
  }

  zle .push-input
  zle .clear-screen
  if (( $+functions[.zle_redraw-prompt] ))  zle .zle_redraw-prompt

  if [[ $ZSHRC_PROMPT_STASHED_NEWLINE ]]  .zshrc_prompt-prepend-newline
}
zle -N       .zle_push-line-and-clear
bindkey '^L' .zle_push-line-and-clear  # ctrl+l

# -- Folder Navigation: Home --
# Key: ctrl+~
# Optional: .zle_redraw-prompt
.zle_cd-home () {
  cd
  if (( $+functions[.zle_redraw-prompt] ))  zle .zle_redraw-prompt
}
zle -N       .zle_cd-home
bindkey '^^' .zle_cd-home  # ctrl+~

# -- Folder Navigation: Down --
# Key: alt+down
# Superseded in broot.zsh
.zle_cd-down () {
  zle .push-input
  LBUFFER="cd "
  zle .menu-expand-or-complete
  # zle .expand-or-complete
}
zle -N            .zle_cd-down
bindkey '^[[1;3B' .zle_cd-down  # alt+down

# ------------------------------------
# Folder Navigation: Up, Back, Forward
# ------------------------------------
# Keys: alt+{up,left,right}
# Optional: .zle_redraw-prompt
# Credit: Roman Perepelitsa
# Original: https://github.com/romkatv/zsh4humans/blob/v2/fn/-z4h-cd-rotate

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
