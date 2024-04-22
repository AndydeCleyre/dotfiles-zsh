# -- .zshrc_load-plugin, .zshrc_fortnightly, .zshrc_upgrade-plugins, ZSH_PLUGINS_DIR --
. ${${(%):-%x}:P:h}/plugin_manager.zsh

# -----------------
# Configure plugins
# -----------------

# -- zpy --
# zstyle ':zpy:*' exposed-funcs zpy pipz a8 envin envout pipup vrun

# -- zsh-z --
ZSHZ_CMD=j
ZSHZ_NO_RESOLVE_SYMLINKS=1
ZSHZ_UNCOMMON=1

# ---------------------------------
# Load some plugins before compinit
# ---------------------------------

# -- Generated Sources --
.zshrc_fortnightly mise  ${XDG_DATA_HOME:-~/.local/share}/zsh/site-functions/_mise  mise complete -s zsh               || true
.zshrc_fortnightly ruff  ${XDG_DATA_HOME:-~/.local/share}/zsh/site-functions/_ruff  ruff generate-shell-completion zsh || true
.zshrc_fortnightly uv    ${XDG_DATA_HOME:-~/.local/share}/zsh/site-functions/_uv    uv generate-shell-completion zsh   || true
.zshrc_fortnightly prqlc ${XDG_DATA_HOME:-~/.local/share}/zsh/site-functions/_prqlc prqlc shell-completion zsh         || true

# -- Load if found --
.zshrc_load-plugin zsh-completions zsh-z

# --------
# compinit
# --------

autoload -Uz compinit
mkdir -p       ${XDG_CACHE_HOME:-~/.cache}/zsh
compinit -i -d ${XDG_CACHE_HOME:-~/.cache}/zsh/zcompdump-$ZSH_VERSION

# --------------------------------
# Load some plugins after compinit
# --------------------------------

# -- Generated Sources --
if { .zshrc_fortnightly pip  ${ZSH_PLUGINS_DIR}/pip.zsh  pip completion -z }  . ${ZSH_PLUGINS_DIR}/pip.zsh
if { .zshrc_fortnightly mise ${ZSH_PLUGINS_DIR}/mise.zsh mise activate zsh }  . ${ZSH_PLUGINS_DIR}/mise.zsh

# -- Load if found --
.zshrc_load-plugin fast-syntax-highlighting agkozak-zsh-prompt
if ! (( $+functions[agkozak-zsh-prompt_plugin_unload] ))  .zshrc_load-plugin --try ${ZSH_PLUGINS_DIR}/powerlevel10k/powerlevel10k.zsh-theme
.zshrc_load-plugin --try /usr/share/doc/pkgfile/command-not-found.zsh /etc/zsh_command_not_found
.zshrc_load-plugin --try ~/Code/zpy ${ZSH_PLUGINS_DIR}/zpy
