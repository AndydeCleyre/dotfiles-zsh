# --  --
pie () {
  emulate -L zsh
  local cmd=(pip install -e .)
  if (( $+commands[uv] ))  cmd=(uv pip install -p python -e .)
  $cmd
}

alias i="ipython"
alias ddg="ddgr -n 3 -x"
alias define="camb"
alias def="cambd"
alias rb="rainbow"
if (( $+commands[trash] ))  alias rm="trash --verbose"

if (( $+functions[compdef] )) && (( $+commands[nt2json] ))  compdef _gnu_generic nt2yaml nt2toml nt2json json2nt toml2nt yaml2nt

# -- Use wheezy.template similarly to jq and jello --
# Depends: wheezy.template (PyPI)
# Pipe JSON to it, and provide template content as args.
# @j is the JSON. Examples:
#   <pyrightconfig.json wz '@j["venvPath"] is the parent path and @j["venv"] is the folder'
#   <pyrightconfig.json wz '@(print(as_json(j)))'
#   <pyrightconfig.json wz '@(x=as_json(j))@x'
# See https://wheezytemplate.readthedocs.io/en/latest/userguide.html#core-extension
wz () {  # <template line>...
  emulate -L zsh

  local tmpl=(
    '@require(__args__)' '@('
    'from json import dumps as as_json'
    'from os import environ as env'
    'j=__args__[0]'
    ')\' $@
  )

  local data
  if [[ -t 0 ]] {
    data='{}'
  } else {
    data=$(<&0)
  }

  wheezy.template =(<<<${(F)tmpl}) =(<<<$data)
}

# -- yt-dlp, interactively choose quality --
# Depends:
#   - yt-dlp (PyPI)
#   - xclip
yt () {  # [[<yt-dlp arg>...] <uri>]
  emulate -L zsh

  local uri=${@[-1]:-$(xclip -sel clip -o)}
  if [[ $@ ]]  shift -p

  local quality
  print -u2 "Quality?"
  select quality ( 540 720 1080 best ) { break }

  local args=($@)
  if [[ $quality ]]  args+=(-S "res:$quality")

  yt-dlp $args "$uri"
}

# -- Like yt above, but for Dropout --
# Depends:
#   - yt-dlp (PyPI)
#   - sops (not Python)
#   - ~/sops/netrc.enc
# TODO: wayland paste
dropout () {  # [<url>=<clipboard>]
  emulate -L zsh

  local cmd=(
    yt-dlp
    -n --netrc-location {}
    --referer https://www.dropout.tv/
    "${@:-$(xclip -sel clip -o)}"
  )

  local quality
  print -u2 "Quality?"
  select quality ( 540 720 1080 best ) { break }
  if [[ $quality ]]  cmd+=(-S "res:$quality")

  sops exec-file --no-fifo ~/sops/netrc.enc "$cmd"
}

# -- Install a tool from PyPI --
# Depends: zpy, uv, or pipx
pypi-install () {  # <pkg>
  emulate -L zsh

  local installcmd=()

  if (( $+functions[pipz] )) {
    installcmd=(pipz install)
  } elif (( $+commands[uv] )) {
    installcmd=(uv tool install)
  } elif (( $+commands[pipx] )) {
    installcmd=(pipx install)
  } else {
    print -lu2 'None of these were found:' '  - zpy' '  - uv' '  - pipx'
    return 1
  }

  print -ru2 "Install $1 with ${installcmd[1]}? [yN] "
  if ! { read -q }  return 1

  $installcmd $1
}

# -- Completion Help Messages --
# Depends: .zshrc_help_complete (help.zsh)
if (( $+functions[.zshrc_help_complete] ))  .zshrc_help_complete dropout pie pypi-install wz yt
