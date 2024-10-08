pie () {
  emulate -L zsh
  local cmd=(pip install -e .)
  if (( $+commands[uv] ))  cmd=(uv pip install -p python -e .)
  $cmd
}

alias i="ipython"
alias ddg="ddgr -n 3 -x"
alias define="camb"
alias rb="rainbow"
if (( $+commands[trash] ))  alias rm="trash --verbose"

if (( $+functions[compdef] )) && (( $+commands[nt2json] ))  compdef _gnu_generic nt2yaml nt2toml nt2json json2nt toml2nt yaml2nt

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
    -f http-540p
    "${@:-$(xclip -sel clip -o)}"
  )
  sops exec-file --no-fifo ~/sops/netrc.enc "$cmd"
}
