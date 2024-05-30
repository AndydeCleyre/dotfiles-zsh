# -- y: best available pacman-like package manager --
if (( $+commands[paru] )) {
  alias y="paru"
} elif (( $+commands[pacman] )) {
  alias y="pacman"
} else {
  alias y="pacaptr"
}

# -- pacman-like interface to distro package managers --
# Prompts to install itself from the latest GitHub release.
# Depends:
#   - tar (any)
#   - wget (any) OR curl
pacaptr () {
  emulate -L zsh -o extendedglob
  rehash

  if ! (( $+commands[pacaptr] )) {
    print -u2 'Download pacaptr to -- ~/.local/bin/ -- ? '
    if ! { read -q }  return 1

    print -rlu2 '' "-- Just a moment... --"

    local netget=(wget -qO -)
    if ! (( $+commands[wget] ))  netget=(curl -sSL)

    local lines=(${(f)"$($netget 'https://api.github.com/repos/rami3l/pacaptr/releases/latest')"})
    local tag=${${${(M)lines:# #\"tag_name\"*}##*\": \"}%\",*}

    mkdir -p ~/.local/bin
    $netget https://github.com/rami3l/pacaptr/releases/download/${tag}/pacaptr-linux-amd64.tar.gz | tar xz -C ~/.local/bin pacaptr

    rehash
  }

  =pacaptr $@
}
