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
# Depends: gh-install (github.zsh)
pacaptr () {
  emulate -L zsh -o errreturn
  rehash

  if ! (( $+commands[pacaptr] ))  gh-install rami3l pacaptr pacaptr-linux-amd64.tar.gz pacaptr

  =pacaptr $@
}
