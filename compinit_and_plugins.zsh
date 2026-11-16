# -- Import Plugin Helpers --
. ${${(%):-%x}:P:h}/plugin_manager.zsh
# - .zshrc::add-pytool-fpath-entries
# - .zshrc::generate-and-load-plugin
# - .zshrc::generate-fpath-completions
# - .zshrc::generate-fpath-completions-click
# - .zshrc::load-plugin

# -----------------
# Configure plugins
# -----------------

# -- mise --
export MISE_PARANOID=1

# -- zpy --
# zstyle ':zpy:*' exposed-funcs \
#   zpy pipz a8 envin envout pipup vrun

# -- fzf --
FZF_ALT_C_COMMAND=
FZF_CTRL_T_COMMAND=

# -- zsh-z --
ZSHZ_CMD=j
ZSHZ_NO_RESOLVE_SYMLINKS=1
ZSHZ_TILDE=1
ZSHZ_UNCOMMON=1

# ------------------------------------------------
# Modify fpath entries and content before compinit
# ------------------------------------------------

# command-not-found doesn't need to be before compinit,
# but must be before mise activation:
.zshrc::load-plugin --try \
  /usr/share/doc/pkgfile/command-not-found.zsh \
  /etc/zsh_command_not_found \
  || true

# If any plugins might be used in mise enter hooks,
# see bottom of file for workaround.
.zshrc::generate-and-load-plugin mise activate zsh  # may be needed for some tools below
.zshrc::generate-fpath-completions \
  'devbox completion zsh' \
  'gh completion -s zsh' \
  'hson --completions zsh' \
  'leaf --auto-complete zsh:dump' \
  'mise completion zsh' \
  'niri completions zsh' \
  'pixi completion --shell zsh' \
  'prqlc shell-completion zsh' \
  'ruff generate-shell-completion zsh' \
  'splash completion zsh' \
  'tdl completion zsh' \
  'tsk completion -s zsh' \
  'uv generate-shell-completion zsh' \
  'yage --completion zsh' \
  'zsh-patina completion'
  # consider killing: devbox, pixi, tdl, niri, splash

.zshrc::generate-fpath-completions-click \
  pip-compile \
  pip-sync \
  hap

.zshrc::add-pytool-fpath-entries \
  yt-dlp

.zshrc::load-plugin \
  zsh-completions \
  zsh-z

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
  zpy

if ! (( $+functions[agkozak-zsh-prompt_plugin_unload] ))  .zshrc::load-plugin powerlevel10k

.zshrc::generate-and-load-plugin --unless-system _pip pip completion -z
.zshrc::generate-and-load-plugin                      fzf --zsh

if { .zshrc::generate-and-load-plugin zsh-patina activate } {
  unfunction zsh-patina  # Disregard hard-coded bin path in generated function
  =zsh-patina start
} else {
  .zshrc::load-plugin fast-syntax-highlighting
}

# -----------------------------------------------------------
# Workaround for https://github.com/jdx/mise/discussions/4217
# -----------------------------------------------------------

# .zshrc::generate-and-load-plugin mise activate zsh
# .zshrc::generate-fpath-completions ...

# This would ideally be under "Modify fpath entries and content before compinit" above,
# *before* compinit.

# If it's down here, 
# the affected tools' completions won't be available 
# in the very first shell launched after their installation.

# The problem:
#   I want mise enter hooks to run after the plugins that must run after compinit,
#   but add tools to the path before .zshrc::generate-fpath-completions, which must be before compinit.

# The constraints, pairwise, 
# where zpy represents any plugin 
# which might be used in a mise enter hook:

#   mise activation (to get tools on PATH) BEFORE .zshrc::generate-fpath-completions
#   .zshrc::generate-fpath-completions     BEFORE compinit
#   compinit                               BEFORE .zshrc::load-plugin zpy
#   .zshrc::load-plugin zpy                BEFORE mise activation (to run enter hooks)
#   command-not-found.zsh                  BEFORE mise activation (to define command not found)

# So "mise activation" is doing three different things here,
# each of which has its own ordering needs among other startup tasks.

# mise activation will also need to be before loading the fzf plugin,
# if fzf is installed via mise.

# --------------------------------
# Custom completions using plugins
# --------------------------------

# -- Complete current argument using zsh-z's DB of visited directories --
# Key: alt+j (or esc, j)
# Depends: zsh-z
if (( $+functions[zshz] )) {
  _zshz_any_arg () {
    words=(zshz ${words[CURRENT]})
    CURRENT=2
    _normal
  }
  zle -C zshz-complete complete-word _generic
  zstyle ':completion:zshz-complete:*' completer _zshz_any_arg
  bindkey '^[j' zshz-complete  # alt+j or esc, j
}
