# --  --
pie () {
  emulate -L zsh
  local cmd=(pip install -e .)
  if (( $+commands[uv] ))  cmd=(uv pip install -p python -e .)
  $cmd
}

alias i="ipython"
alias ddg="ddgr -n 3 -x"
alias def="camb -w"
alias define="cambd"
alias rb="rainbow"
# if (( $+commands[trash] ))  alias rm="trash --verbose"  # completion for trash is worse than for rm
if (( $+commands[trash] ))  rm () { trash --verbose $@ }

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
#   - yt-dlp (PyPI) -- yt-dlp[default,curl-cffi] recommended
#   - xclip
# Optional: zpick (unsorted_functions.zsh)
yt () {  # [[<yt-dlp arg>...] <uri>]
  emulate -L zsh

  local uri=${@[-1]:-$(xclip -sel clip -o)}
  if [[ $@ ]]  shift -p

  local quality
  print -u2 "Quality?"
  if (( $+functions[zpick] )) {
    local REPLY
    zpick best 1080 720 540
    quality=$REPLY
  } else {
    select quality ( best 1080 720 540 ) { break }
  }

  local args=(
    --embed-metadata
    --embed-subs
    --no-playlist
    --extractor-args "generic:impersonate"
    $@
  )
  if [[ $quality && $quality != best ]]  args+=(-f "bestvideo[height<=$quality]+bestaudio/best[height<=$quality]")

  yt-dlp $args "$uri"
}

# -- Like yt above, but for Dropout --
# Depends:
#   - yt-dlp (PyPI)
#   - rage
#   - ~/Crypt/keys/dropout.txt
#   - ~/Crypt/corpses/netrc.age
# Optional: zpick (unsorted_functions.zsh)
# TODO: wayland paste
dropout () {  # [<url>=<clipboard>]
  emulate -L zsh

  local cmd=(
    yt-dlp
    --netrc-cmd "rage -d -i $HOME/Crypt/keys/dropout.txt $HOME/Crypt/coffins/netrc.age"
    --referer https://www.dropout.tv/
    --embed-metadata
    --embed-subs
    "${@:-$(xclip -sel clip -o)}"
  )

  local quality
  print -u2 "Quality?"
  if (( $+functions[zpick] )) {
    local REPLY
    zpick 540 720 1080 best
    quality=$REPLY
  } else {
    select quality ( 540 720 1080 best ) { break }
  }

  if [[ $quality && $quality != best ]]  args+=(-f "bestvideo[height<=$quality]+bestaudio/best[height<=$quality]")

  $cmd
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
