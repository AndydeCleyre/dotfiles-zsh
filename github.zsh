# -- Install binary release from GitHub --
# Depends:
#   - gunzip (any)
#   - tar (any)
#   - wget (any) OR curl
gh-install () {  # <gh-owner> <gh-repo> <archive-name> <src-bin-name> [<dst-bin-name> [<dest>=~/.local/bin]]
  emulate -L zsh -o extendedglob -o errreturn
  rehash

  local ghowner ghrepo tgz srcbin dstbin dest
  ghowner=$1 ; shift
  ghrepo=$1  ; shift
  tgz=$1     ; shift
  srcbin=$1  ; shift
  if [[ $1 ]] {
    dstbin=$1; shift
  } else {
    dstbin=$srcbin
  }
  dest=${1:-~/.local/bin}
  [[ $ghowner && $ghrepo && $tgz && $srcbin && $dstbin && $dest ]]

  local netget=(wget -qO -)
  if ! (( $+commands[wget] ))  netget=(curl -sSL)

  local lines=(${(f)"$($netget "https://api.github.com/repos/${ghowner}/${ghrepo}/releases/latest")"})
  local tag=${${${(M)lines:# #\"tag_name\"*}##*\": \"}%\",*}

  if (( $+commands[$dstbin] ))  $dstbin --version
  print -u2 "Available: $tag"
  print -u2 "Download $dstbin to -- $dest -- ? "
  if ! { read -q }  return 1

  print -rlu2 '' '-- Just a moment... --'
  mkdir -p "$dest"
  if [[ $tgz == *.tar.gz ]] {
    $netget "https://github.com/${ghowner}/${ghrepo}/releases/download/${tag}/${tgz}" | tar xz -C "$dest" "$srcbin"
    if [[ $srcbin != $dstbin ]]  mv -i "${dest}/${srcbin}" "${dest}/${dstbin}"
  } elif [[ $tgz == *.gz ]] {
    $netget "https://github.com/${ghowner}/${ghrepo}/releases/download/${tag}/${tgz}" | gunzip -c >"${dest}/${dstbin}"
  } else { return 1 }
  chmod +x "${dest}/${dstbin}"

  rehash
}

# -- xmq for html and xml --
# Prompts to install itself from the latest GitHub release.
# Depends: gh-install (github.zsh)
xmq () {
  emulate -L zsh -o errreturn
  rehash

  if ! (( $+commands[xmq] ))  gh-install libxmq xmq xmq-gnulinux-release.gz xmq

  =xmq $@
}
