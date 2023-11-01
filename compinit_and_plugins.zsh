# -- .zshrc_load-plugin, .zshrc_fortnightly, .zshrc_upgrade-plugins, ZSH_PLUGINS_DIR --
# Unloaded later: .zshrc_load-plugin, .zshrc_fortnightly
. ${${(%):-%x}:P:h}/plugin_manager.zsh

# -----------------
# Configure plugins
# -----------------

# -- agkozak-zsh-prompt --
# see prompt.zsh

# -- zpy --
# zstyle ':zpy:*' exposed-funcs zpy pipz a8 envin envout pipup vrun

# -- zsh-z --
ZSHZ_CMD=j
ZSHZ_NO_RESOLVE_SYMLINKS=1
ZSHZ_UNCOMMON=1

# ---------------------------------
# Load some plugins before compinit
# ---------------------------------

# -- Single Location Sources --
.zshrc_load-plugin \
  zsh-defer \
  zsh-completions \
  zsh-z

# -- Generated Sources --
.zshrc_fortnightly rtx \
  ${XDG_DATA_HOME:-~/.local/share}/zsh/site-functions/_rtx \
  rtx complete -s zsh

# --------
# compinit
# --------

autoload -Uz compinit
compinit -id ${XDG_CACHE_HOME:-~/.cache}/zsh/zcompdump-$ZSH_VERSION  # mkdir needed?

# --------------------------------
# Load some plugins after compinit
# --------------------------------

# -- Alternate Location Sources --
.zshrc_load-plugin --try \
  /usr/share/doc/pkgfile/command-not-found.zsh \
  /etc/zsh_command_not_found
.zshrc_load-plugin --try \
  ~/Code/zpy \
  ${ZSH_PLUGINS_DIR}/zpy

# -- Single Location Sources --
.zshrc_load-plugin \
  fast-syntax-highlighting \
  agkozak-zsh-prompt \
  zsh-autoenv

# -- Generated Sources --
if { .zshrc_fortnightly pip ${ZSH_PLUGINS_DIR}/pip.zsh pip completion -z }  . ${ZSH_PLUGINS_DIR}/pip.zsh
if { .zshrc_fortnightly rtx ${ZSH_PLUGINS_DIR}/rtx.zsh rtx activate zsh  }  . ${ZSH_PLUGINS_DIR}/rtx.zsh

# -------
# Cleanup
# -------

unfunction .zshrc_load-plugin .zshrc_fortnightly
