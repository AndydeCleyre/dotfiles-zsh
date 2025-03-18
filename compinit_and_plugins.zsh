# -- .zshrc_load-plugin, .zshrc_fortnightly, ZSH_PLUGINS_DIR --
. ${${(%):-%x}:P:h}/plugin_manager.zsh

# -----------------
# Configure plugins
# -----------------

# -- mise --
export MISE_PARANOID=1

# -- zpy --
# zstyle ':zpy:*' exposed-funcs zpy pipz a8 envin envout pipup vrun

# -- zsh-fzf-history-search --
ZSH_FZF_HISTORY_SEARCH_DATES_IN_SEARCH=0
ZSH_FZF_HISTORY_SEARCH_EVENT_NUMBERS=0

# -- zsh-z --
ZSHZ_CMD=j
ZSHZ_NO_RESOLVE_SYMLINKS=1
ZSHZ_UNCOMMON=1

# -------------------------------------------------
# Load completions and some plugins before compinit
# -------------------------------------------------

# -- Generated Sources --
# TODO: https://github.com/jdx/mise/discussions/4217
() {
  emulate -L zsh
  local generator words
  for generator (
    'gh completion -s zsh'
    'mise completion zsh'
    'prqlc shell-completion zsh'
    'ruff generate-shell-completion zsh'
    'tsk completion -s zsh'
    'uv generate-shell-completion zsh'
    'yage --completion zsh'
  ) {
    words=(${(z)generator})
    .zshrc_fortnightly \
      --unless _${words[1]} \
      ${words[1]} \
      ${XDG_DATA_HOME:-~/.local/share}/zsh/site-functions/_${words[1]} \
      $words || true
  }
}

# -- Load if found --
.zshrc_load-plugin zsh-completions zsh-z
.zshrc_load-plugin --try /usr/share/doc/pkgfile/command-not-found.zsh /etc/zsh_command_not_found  # before mise activation

# --------
# compinit
# --------

autoload -Uz compinit
mkdir -p       ${XDG_CACHE_HOME:-~/.cache}/zsh
compinit -i -d ${XDG_CACHE_HOME:-~/.cache}/zsh/zcompdump-$ZSH_VERSION

# --------------------------------
# Load some plugins after compinit
# --------------------------------

# -- Load if found --
.zshrc_load-plugin agkozak-zsh-prompt fast-syntax-highlighting zpy zsh-autoenv zsh-fzf-history-search
if ! (( $+functions[agkozak-zsh-prompt_plugin_unload] ))  .zshrc_load-plugin --try ${ZSH_PLUGINS_DIR}/powerlevel10k/powerlevel10k.zsh-theme

# -- Generated Sources --
if { .zshrc_fortnightly --unless _pip pip  ${ZSH_PLUGINS_DIR}/pip.zsh  pip completion -z }  . ${ZSH_PLUGINS_DIR}/pip.zsh
if { .zshrc_fortnightly               mise ${ZSH_PLUGINS_DIR}/mise.zsh mise activate zsh }  . ${ZSH_PLUGINS_DIR}/mise.zsh
