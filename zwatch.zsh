# -- zwatch --
# It's like watch, but also works for functions
# -t           -- disable header
# -n <seconds> -- run command this often
zwatch () {  # [-t] [-n <seconds>=2] <cmd> [<cmd-arg>...]
  emulate -L zsh
  zmodload zsh/zselect

  local seconds=2 print_header=1
  while [[ $1 == -[nt] ]] {
    if [[ $1 == -t ]] {
      print_header=
      shift
      continue
    }
    shift
    seconds=$1
    shift
  }

  local centiseconds=$(( seconds*100 ))

  while (( 1 )) {
    print -n '\e[2J\e[H'
    if [[ $print_header ]] {
      print -rn "Every ${seconds}s: ${(q-)@}"
      print "\t\t${(%):-%D %*}\n"
    }
    eval "${(q-)@}"
    zselect -t $centiseconds || true
  }
}

# -- Prepend zwatch --
# Key: esc, z
.zle_prepend-zwatch () {
  BUFFER="zwatch $BUFFER"
  CURSOR=$#BUFFER

  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N        .zle_prepend-zwatch
bindkey '\ez' .zle_prepend-zwatch  # esc, z

if (( $+functions[.zshrc_help_complete-as-prefix] ))  .zshrc_help_complete-as-prefix zwatch
