# -- ripgrep sugar --
alias rg="=rg --smart-case --hidden --no-ignore --glob '!.git' --glob '!.venv' --glob '!.tox' --glob '!.mypy_cache' --glob '!.nox'"
alias rg1="rg --maxdepth 1"
alias rg2="rg --maxdepth 2"
alias rgm="rg --multiline --multiline-dotall"

# -- grep --
g () {  # <grep-arg>...
  emulate -L zsh
  rehash

  local cmd=(grep -P --color -i)
  if (( $+commands[pcre2grep] )) {
    cmd=(pcre2grep --color -i)
  } elif (( $+commands[pcregrep] )) {
    cmd=(pcregrep --color -i)
  } elif [[ ${commands[grep]:P:t} != grep ]] {
    cmd=(grep -E --color -i)
  }

  $cmd $@
}
alias no="g -v"

# -- Strip comments and blank lines --
fax () {  # [-c <comment-prefix>=#] [<file>...]
  emulate -L zsh

  local comment='#'
  if [[ $1 == -c ]] {
    shift; comment=$1; shift
  }

  if [[ $1 ]] {
    for 1 { grep -Ev '^(\s*'${comment}'|$)' $1 }
  } else  { grep -Ev '^(\s*'${comment}'|$)'    }
}

# -- Strip sensitive info from a config file or stdin --
# Don't rely on it!
# TODO: drop sed?
redact () {  # [<file>]
  emulate -L zsh

  # local secret_assignment=('^(\s*\S*('
  local secret_assignment=('^(.*('
      'user(name)?|_id|acct|login'
      '|passw(or)?d|pw|key|token|secret'
      '|address|email'
      '|blob|data'
      '|History Items\[\$e\]'
      '|calendar_(id_)?list'
  ') ?[=: ] ?)(\S+)$')

  sed -E \
    -e "s/${(j::)secret_assignment}/\1[redacted]/gim" \
    -e 's-(.+://[^:]+:)([^@]+)(@.+)-\1[redacted]\3-g' \
    -e 's/(.*: )?(.*)\\$/\1[redacted]/g' \
    -e 's/^[^"]+"$/[redacted]/g' \
    $@
}

# -- Grab all blocks of text containing regex match --
# A block is text between blank lines
gblock () {  # <term> [<pcre(2)grep-arg>...]
  emulate -L zsh
  rehash

  # TODO: pure zsh with pcre?
  local pattern='(^[^\n]+\n)*[^\n]*'$1'[^\n]*(\n[^\n]+)*'
  shift

  local cmd
  if (( $+commands[rg] )) {
    cmd=(rg -UIN --color never $pattern)
  } elif (( $+commands[pcre2grep] )) {
    cmd=(pcre2grep -Mh $pattern)
  } elif (( $+commands[pcregrep] )) {
    cmd=(pcregrep -Mh $pattern)
  } else {
    print -rlu2 \
      'This function requires one of:' \
      '  - ripgrep (rg)' \
      '  - pcre2grep (pcre2-utils)' \
      '  - pcregrep'
    return 1
  }

  $cmd $@
}

if (( $+functions[.zshrc_help_complete] ))  .zshrc_help_complete g fax redact gblock
