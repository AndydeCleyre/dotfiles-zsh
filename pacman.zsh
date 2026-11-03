# -- y: best available pacman-like package manager --
if (( $+commands[paru] )) {
  alias y="paru"
} elif (( $+commands[pacman] )) {
  alias y="pacman"
} else {
  alias y="pacaptr"
}

alias yd="LD_PRELOAD=${LD_PRELOAD:+$LD_PRELOAD }/usr/lib/libgtk-nocsd.so DIFFPROG=meld MERGEPROG=meld pacdiff -3 -s"

# -- pacman-like interface to distro package managers --
# Optional: gh-install (github.zsh) or mise
pacaptr () {
  emulate -L zsh -o errreturn
  rehash

  if ! (( $+commands[pacaptr] )) {
    if (( $+functions[mise] )) {
      mise use -g github:rami3l/pacaptr
    } elif (( $+functions[gh-install] )) {
      gh-install rami3l pacaptr pacaptr-linux-amd64.tar.gz pacaptr
    }
  }

  =pacaptr $@
}

# -- Prepend pacman -Qo --
# Key: esc, o
.zle::pacman::prepend-owns () {
  local words=(${(z)BUFFER})
  zle .push-line
  LBUFFER="pacman -Qo ${words[1]}"
  
  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N        .zle::pacman::prepend-owns
bindkey '\eo' .zle::pacman::prepend-owns

# -- Prepend pacman -Q --
# Key: esc, q
.zle::pacman::prepend-query () {
  local words=(${(z)BUFFER})
  zle .push-line
  LBUFFER="pacman -Q"
  RBUFFER=" ${words[1]}"
  
  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N        .zle::pacman::prepend-query
bindkey '\eq' .zle::pacman::prepend-query
