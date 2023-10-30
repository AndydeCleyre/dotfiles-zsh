# -------------------------------
# Configure completions and globs
# -------------------------------

setopt \
  always_to_end \
  complete_in_word \
  extendedglob \
  globdots \
  nocaseglob

zstyle ':completion:*:*:*:*:*' menu select

if (( $+commands[dircolors] ))  eval "$(dircolors -b)"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' '+l:|=* r:|=*'
zstyle ':completion:*' accept-exact-dirs 'yes'

zstyle ':completion:*' group-name ''
zstyle ':completion:*' format '%F{yellow}%B-- %d --%b%f'

# mkdir -p ${XDG_CACHE_HOME:-~/.cache}/zsh  # needed? testing...
zstyle ':completion::complete:*' cache-path ${XDG_CACHE_HOME:-~/.cache}/zsh
zstyle ':completion::complete:*' use-cache 1

# -- Complete file path --
# Key: ctrl+/
# Superseded in broot.zsh
zstyle ':completion:complete-files:*' completer _files
zle -C complete-files menu-complete _generic
bindkey '^_' complete-files  # ctrl+/

# -- Previous item in completion menu --
# Key: shift+tab
bindkey '^[[Z' reverse-menu-complete  # shift+tab
