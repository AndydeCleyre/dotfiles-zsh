# -- Install binary release from GitHub --
# Depends:
#   - gunzip (any), tar (any), wget (any) OR curl
# Optional:
#   - wheezy.template (PyPI) + wz (misc_python.zsh), OR jq, OR yamlpath (PyPI), OR dasel
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

  local netget=(wget -U Wget/1.21.2 -qO -)
  if ! (( $+commands[wget] ))  netget=(curl -sSL)

  local tag json_url="https://api.github.com/repos/${ghowner}/${ghrepo}/releases/latest"
  if (( $+commands[wheezy.template] )) && (( $+functions[wz] )) {
    tag=$($netget $json_url | wz '@j["tag_name"]')
  } elif (( $+commands[jq] )) {
    tag=$($netget $json_url | jq -r .tag_name)
  } elif (( $+commands[yaml-get] )) {
    tag=$($netget $json_url | yaml-get -p tag_name)
  } elif (( $+commands[dasel] )) {
    tag=$($netget $json_url | dasel -f - -r json -w - tag_name)
  } else {
    local lines=(${(f)"$($netget $json_url)"})
    local tag=${${${(M)lines:# #\"tag_name\"*}##*\": \"}%\",*}
  }

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

# -- Completion Help Messages --
# Depends: .zshrc_help_complete (help.zsh)
if (( $+functions[.zshrc_help_complete] ))  .zshrc_help_complete gh-install
