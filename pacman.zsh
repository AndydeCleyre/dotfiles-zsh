# -- y: best available pacman-like package manager --
if (( $+commands[paru] )) {
  alias y="paru"
} elif (( $+commands[pacman] )) {
  alias y="pacman"
} else {
  alias y="pacaptr"
}

alias yd="DIFFPROG=meld MERGEPROG=meld pacdiff -3 -s"

# -- pacman-like interface to distro package managers --
# Optional: gh-install (github.zsh) or mise
pacaptr () {
  emulate -L zsh -o errreturn
  rehash

  if ! (( $+commands[pacaptr] )) {
    if (( $+functions[mise] )) {
      mise use -g ubi:rami3l/pacaptr@latest
    } elif (( $+functions[gh-install] )) {
      gh-install rami3l pacaptr pacaptr-linux-amd64.tar.gz pacaptr
    }
  }

  =pacaptr $@
}
