# -- ripgrep sugar --
rg () {
  emulate -L zsh

  local args=(--smart-case --hidden --no-ignore)
  local ignores=('!.git/' '!.venv/' '!venv/' '!.tox/' '!.mypy_cache/' '!.nox/' '!.pytest_cache/')
  args+=(${${ignores/*/--glob}:^ignores})

  =rg $args $@
}
alias rg1="rg --max-depth 1"
alias rg2="rg --max-depth 2"
alias rgm="rg --multiline"

# -- ugrep sugar --
ug () {
  emulate -L zsh

  local args=(--smart-case --glob-ignore-case --hidden --ignore-binary --perl-regexp)
  local ignores=('!.git/' '!.venv/' '!venv/' '!.tox/' '!.mypy_cache/' '!.nox/' '!.pytest_cache/')
  args+=(--glob=${(j:,:)ignores})
  if [[ -t 0 ]] {
    args+=(--recursive)
  } else {
    args+=(--no-line-number)
  }

  =ug $args $@
}

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
  local pattern='(.+\n)*.*'$1'.*(\n.+)*'
  shift

  local cmd=() common=(--no-filename --color=never)
  if (( $+commands[ugrep] )) {
    cmd=(ugrep     $common                              $pattern)
  } elif (( $+commands[rg] )) {
    cmd=(rg        $common --multiline --no-line-number $pattern)
  } elif (( $+commands[pcre2grep] )) {
    cmd=(pcre2grep $common --multiline                  $pattern)
  } elif (( $+commands[pcregrep] )) {
    cmd=(pcregrep  $common --multiline                  $pattern)
  } else {
    print -rlu2 \
      'This function requires one of:' \
      '  - ugrep' \
      '  - rg (ripgrep)' \
      '  - pcre2grep (pcre2-utils)' \
      '  - pcregrep'
    return 1
  }

  $cmd $@
}

if (( $+functions[.zshrc_help_complete] ))  .zshrc_help_complete g fax redact gblock
