# -- Import Plugin Helpers --
. ${${(%):-%x}:P:h}/plugin_manager.zsh
# - .zshrc::load-plugin
# - .zshrc::generate-fpath-completions
# - .zshrc::generate-fpath-completions-click
# - .zshrc::add-pytool-fpath-entries
# - .zshrc::generate-and-load-plugin

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

# ------------------------------------------------
# Modify fpath entries and content before compinit
# ------------------------------------------------

.zshrc::generate-fpath-completions \
  'devbox completion zsh' \
  'gh completion -s zsh' \
  'mise completion zsh' \
  'prqlc shell-completion zsh' \
  'ruff generate-shell-completion zsh' \
  'tsk completion -s zsh' \
  'uv generate-shell-completion zsh' \
  'yage --completion zsh'
.zshrc::generate-fpath-completions-click \
  pip-compile \
  pip-sync

.zshrc::add-pytool-fpath-entries \
  yt-dlp

.zshrc::load-plugin \
  zsh-completions \
  zsh-z
.zshrc::load-plugin --try \
  /usr/share/doc/pkgfile/command-not-found.zsh \
  /etc/zsh_command_not_found  # before mise activation

# --------
# compinit
# --------

autoload -Uz compinit
mkdir -p       ${XDG_CACHE_HOME:-~/.cache}/zsh
compinit -i -d ${XDG_CACHE_HOME:-~/.cache}/zsh/zcompdump-$ZSH_VERSION

# --------------------------------
# Load most plugins after compinit
# --------------------------------

.zshrc::load-plugin \
  agkozak-zsh-prompt \
  fast-syntax-highlighting \
  zpy \
  zsh-autoenv \
  zsh-fzf-history-search
if ! (( $+functions[agkozak-zsh-prompt_plugin_unload] ))  .zshrc::load-plugin powerlevel10k

.zshrc::generate-and-load-plugin --unless-system _pip pip completion -z
.zshrc::generate-and-load-plugin mise activate zsh

compdef _gnu_generic \
  nt2{json,{to,ya}ml} {json,{to,ya}ml}2nt
