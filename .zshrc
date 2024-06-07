precmd () { rehash }

autoload -Uz zargs

: ${ZDOTDIR:=${${(%):-%x}:P:h}}

. ${ZDOTDIR}/inline_selection.zsh
. ${ZDOTDIR}/tmux.zsh  # supersedes key: pgup (load after inline_selection)

. ${ZDOTDIR}/compinit_and_plugins.zsh  # otherwise: autoload -Uz compinit && compinit

. ${ZDOTDIR}/prompt.zsh  # configures prompt plugin if loaded (load after compinit_and_plugins)
. ${ZDOTDIR}/help.zsh    # uses compdef if loaded             (load after compinit_and_plugins)

# -- These use .zshrc_help_complete if loaded (load after help) --
. ${ZDOTDIR}/clipboard.zsh
. ${ZDOTDIR}/files.zsh
. ${ZDOTDIR}/find.zsh
. ${ZDOTDIR}/git.zsh
. ${ZDOTDIR}/grep.zsh
. ${ZDOTDIR}/ls.zsh
. ${ZDOTDIR}/paging_and_printing.zsh
. ${ZDOTDIR}/zwatch.zsh

. ${ZDOTDIR}/cd.zsh
. ${ZDOTDIR}/clear_and_foldernav.zsh
. ${ZDOTDIR}/completion_and_glob_opts.zsh
. ${ZDOTDIR}/editor.zsh
. ${ZDOTDIR}/github.zsh
. ${ZDOTDIR}/history.zsh
. ${ZDOTDIR}/misc_python.zsh
. ${ZDOTDIR}/misc_zle.zsh
. ${ZDOTDIR}/multiline_enter.zsh
. ${ZDOTDIR}/pacman.zsh  # uses gh-install (github.zsh) for pacaptr installation function
. ${ZDOTDIR}/broot.zsh  # supersedes keys:
                        #   - ctrl+/   (load after completion_and_glob_opts)
                        #   - alt+down (load after clear_and_foldernav)

# if [[ -r ${ZDOTDIR}/unsorted.zsh ]]  . ${ZDOTDIR}/unsorted.zsh  # TODO: mostly empty this

# If commenting most lines,
# top items to consider:
#
#   - prompt
#   - inline_selection
#   - misc_zle
#   - history
#   - paging_and_printing
#   - completion_and_glob_opts
#   - help
