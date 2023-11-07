alias pie="pip install -e ."
alias i="ipython"

alias ddg="ddgr -n 3 -x"
alias define="cambrinary -w"

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
