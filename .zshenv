# This needs a link at ~/.zshenv

LANG=en_US.UTF-8

# -----------------
# Desktop Standards
# -----------------

# XDG_CONFIG_HOME=~/.config
# XDG_CACHE_HOME=~/.cache
# XDG_DATA_HOME=~/.local/share
# XDG_STATE_HOME=~/.local/state

# XDG_RUNTIME_DIR=/run/user/$UID
# XDG_DATA_DIRS=/usr/local/share:/usr/share
# XDG_CONFIG_DIRS=/etc/xdg

# ------------------------
# PATH, fpath, and ZDOTDIR
# ------------------------

# -- PATH --
typeset -U path=(
  ~/.local/bin
  $path
  /usr/lib/execline/bin
)

# -- fpath --
mkdir -p ${XDG_DATA_HOME:-~/.local/share}/zsh/site-functions
typeset -U fpath=(
  ${XDG_DATA_HOME:-~/.local/share}/zsh/site-functions
  /usr/local/share/zsh/site-functions
  $fpath
  /usr/share/zsh/site-functions
)

# -- ZDOTDIR, home of .zshrc --
ZDOTDIR=${${(%):-%x}:P:h}  # this file's (realpath's) parent folder

# --------------------------------
# Disable some distro interference
# --------------------------------

DEBIAN_PREVENT_KEYBOARD_CHANGES=1
skip_global_compinit=1
setopt noglobalrcs
