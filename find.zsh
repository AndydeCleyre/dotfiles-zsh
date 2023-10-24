# -- Find by part of the basename, then successively filter (globby) --
# -F -- don't follow linked folders
fnd () {  # [-F] <leaf-term> [<term>...]
  emulate -L zsh -o extendedglob -o globdots

  local matches=()
  if [[ $1 == -F ]] {
    shift
    matches=(**/*(#l)$1*)
  } else {
    matches=(***/*(#l)$1*)
  }
  shift
  for 1 { matches=(${(M)matches:#*(#l)$1*}) }

  print -rl -- $matches
}

# -- Locate by regex, then successively filter --
# Depends:
#   - plocate
#   - grep (any)
# TODO:
#   - drop grep
#   - drop eval
loc () {  # <regex-term>...
  emulate -L zsh

  local cmd=(locate -i --regex ${(q-)1})
  shift
  for 1 { cmd+=('|' grep -iE --color ${(q-)1}) }

  eval $cmd
}
alias locu="doas updatedb && loc"
alias uloc="doas updatedb && loc"

if (( $+functions[.zshrc_help_complete] ))  .zshrc_help_complete fnd loc
