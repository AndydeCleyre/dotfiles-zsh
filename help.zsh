# -- Smarter-than-man help for current command --
# Key: esc, h
if (( $+aliases[run-help] )) {
  unalias run-help
  autoload -Uz run-help
}

alias huh="typeset -p"

# -- Get help text for a function, alias, or command --
# Sets: REPLY
.zshrc_help () {  # (<zshrc>|<function>|<alias>)
  emulate -L zsh
  unset REPLY
  rehash

  local funcname=$1
  local pattern='^(#[^\n]*\n)*^(alias '$funcname'=[^\n]+|'$funcname' ?\([^\n]*)'

  local files=(${ZDOTDIR:-~}/*zsh(|rc|env)(.D))

  local cmd=()
  if (( $+commands[rg] )) {
    cmd+=(rg -UNI)
  } elif (( $+commands[pcre2grep] )) {
    cmd+=(pcre2grep -Mh)
  } elif (( $+commands[pcregrep] )) {
    cmd+=(pcregrep -Mh)
  } else {
    print -u2 'Not found: ripgrep, pcre2grep, or pcregrep'
    return 2
  }

  local content=$($cmd $pattern $files)
  content=${content/ \(\) \{  \# / }
  if [[ ! $content ]]  content=$(whence -c -x 2 $funcname)
  REPLY=$content
}

# -- Show completion message for a function --
# Depends: .zshrc_help
_zshrc_help () {  # <funcname>
  setopt localoptions extendedglob

  local msg REPLY
  .zshrc_help $1
  msg=(${(f)REPLY})
  msg=(${msg//#(#b)([^#]*)/%B${match[1]}%b})
  if ! [[ -v NO_COLOR ]]  msg=(${msg//#(#b)(\#*)/%F{blue}$match[1]%f})

  _message -r ${(F)msg}
}

# -- Generate completion functions showing help message --
.zshrc_help_complete () {  # <funcname...>
  if (( $+functions[compdef] )) {
    for 1 {
      _$1 () {
        _zshrc_help ${0[2,-1]}
        _files
      }
      compdef _$1 $1
    }
  }
}
.zshrc_help_complete-as-prefix () {  # <funcname...>
  if (( $+functions[compdef] )) {
    for 1 {
      _$1 () {
        _zshrc_help ${0[2,-1]}
        shift words
        (( CURRENT-=1 ))
        _normal -P
      }
      compdef _$1 $1
    }
  }
}

# -- Print location/content/help of a function/alias/command/parameter  --
# Depends: .zshrc_help
# Optional:
#   - h (paging_and_printing.zsh)
#   - tldr (PyPI)
# TODO:
#   - alias tracking?
wh () {  # <funcname>
  emulate -L zsh -o extendedglob
  rehash

  # -- Highlighting --
  # Only if shell is interactive and function h is available
  .zshrc_wh-hszsh () {
    if [[ -t 1 ]] && (( $+functions[h] )) {
      h -s zsh
    } else {
      >&1
    }
  }

  if [[ ! $1 || $1 =~ '^-' ]] {
    local REPLY
    .zshrc_help $0
    <<<$REPLY .zshrc_wh-hszsh
    return
  }

  local funcname=$1

  local pattern='^(#[^\n]*\n)*^('$funcname' ?\(([^\n]*|[\s\S]*?\n)\}$|alias '$funcname'=[^\n]+)'

  local cmd=() can_search=1
  if (( $+commands[rg] )) {
    cmd+=(rg -UNI)
  } elif (( $+commands[pcre2grep] )) {
    cmd+=(pcre2grep -Mh)
  } elif (( $+commands[pcregrep] )) {
    cmd+=(pcregrep -Mh)
  } else {
    print -u2 'Not found: ripgrep, pcre2grep, or pcregrep'
    can_search=
  }

  # -- Show function info --
  if (( $+functions[$funcname] )) {
    local src=${functions_source[$funcname]}
    [[ $src ]] || can_search=

    if [[ -t 1 ]]  whence -v $funcname
    if [[ $can_search ]] {
      $cmd $pattern $src | .zshrc_wh-hszsh
      if ! [[ ${pipestatus:#0} ]]  return
    }
    whence -c -x 2 $funcname | .zshrc_wh-hszsh

  # -- Show alias info --
  } elif (( $+aliases[$funcname] )) {
    local files=(${ZDOTDIR:-~}/*zsh(|rc|env)(.D))

    if [[ -t 1 ]]  whence -v $funcname
    if [[ $can_search ]] {
      $cmd $pattern $files | .zshrc_wh-hszsh
      if ! [[ ${pipestatus:#0} ]]  return
    }
    whence -f $funcname | .zshrc_wh-hszsh

  # -- Show parameter info --
  } elif [[ -v $funcname ]] {
    typeset -p $funcname | .zshrc_wh-hszsh

  # -- Desperately flail for info --
  } else {
    run-help $funcname
    whence -as $funcname
    if (( $+commands[tldr] ))  tldr $funcname
  }

  # -- Cleanup --
  unfunction .zshrc_wh-hszsh
}

.zshrc_help_complete-as-prefix wh

# -- Prepend wh --
# Key: esc, w
.zle_prepend-wh () {
  local words=(${(z)BUFFER})
  zle .push-line
  LBUFFER="wh ${words[1]}"

  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N        .zle_prepend-wh
bindkey '\ew' .zle_prepend-wh  # esc, w

# -- Prepend tldr --
# Key: esc, t
.zle_prepend-tldr () {
  local words=(${(z)BUFFER})
  zle .push-line
  LBUFFER="tldr ${words[1]}"

  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N        .zle_prepend-tldr
bindkey '\et' .zle_prepend-tldr  # esc, t

# -- View portions of the Zsh man pages --
# Depends: mansnip-kristopolous (PyPI)
mz () {  # <search-term>...
  if [[ $@ ]] {
    mansnip zshall $@
  } else {
    man zshall
  }
}
