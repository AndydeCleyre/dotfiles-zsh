# -- Refresh prompt, rerunning any hooks --
# Credit: Roman Perepelitsa
# Original: https://github.com/romkatv/zsh4humans/blob/v2/fn/-z4h-redraw-prompt
.zle::redraw-prompt () {
  for 1 ( chpwd $chpwd_functions precmd $precmd_functions ) {
    if (( $+functions[$1] ))  $1 &>/dev/null
  }
  zle .reset-prompt
  zle -R
}
zle -N .zle::redraw-prompt

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

# -- Screen Clearing with Prompt Redraw --
# Clear screen and redraw prompt, and remove any leading newline
# Optional: .zle::redraw-prompt, .zshrc_prompt-{remove-leading,prepend}-newline
.zle::clear-screen-and-redraw () {
  ZSHRC_PROMPT_STASHED_NEWLINE=
  if (( ! $+functions[p10k] )) && (( $+functions[.zshrc_prompt-remove-leading-newline] )) {
    if { .zshrc_prompt-remove-leading-newline }  ZSHRC_PROMPT_STASHED_NEWLINE=1
  }

  zle .clear-screen

  if (( $+functions[_p9k_widget_hook] )) {
    _p9k_widget_hook clear-screen
  } elif (( $+functions[.zle::redraw-prompt] )) {
    zle .zle::redraw-prompt
  }

  if [[ $ZSHRC_PROMPT_STASHED_NEWLINE ]]  .zshrc_prompt-prepend-newline
}
zle -N .zle::clear-screen-and-redraw
