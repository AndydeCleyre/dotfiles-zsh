precmd () { rehash }

autoload -Uz zargs

: ${ZDOTDIR:=${${(%):-%x}:P:h}}

. ${ZDOTDIR}/inline_selection.zsh
. ${ZDOTDIR}/tmux.zsh  # supersedes key: pgup (load after inline_selection)

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] {
  . "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
}

# Comment out if using Rio terminal:
# ZSHRC_PAD_ICONS=1  # before prompt and ls

. ${ZDOTDIR}/compinit_and_plugins.zsh  # otherwise: autoload -Uz compinit && compinit

. ${ZDOTDIR}/prompt.zsh  # configures prompt plugin if loaded (load after compinit_and_plugins)
. ${ZDOTDIR}/help.zsh    # uses compdef if loaded             (load after compinit_and_plugins)

# -- These use .zshrc_help_complete if loaded (load after help) --
. ${ZDOTDIR}/clipboard.zsh
. ${ZDOTDIR}/files.zsh
. ${ZDOTDIR}/find.zsh
. ${ZDOTDIR}/git.zsh
. ${ZDOTDIR}/github.zsh
. ${ZDOTDIR}/grep.zsh
. ${ZDOTDIR}/ls.zsh
. ${ZDOTDIR}/misc_python.zsh
. ${ZDOTDIR}/paging_and_printing.zsh
. ${ZDOTDIR}/zwatch.zsh
. ${ZDOTDIR}/unsorted_functions.zsh

. ${ZDOTDIR}/cd.zsh
. ${ZDOTDIR}/clear_and_foldernav.zsh
. ${ZDOTDIR}/completion_and_glob_opts.zsh
. ${ZDOTDIR}/editor.zsh
. ${ZDOTDIR}/history.zsh
. ${ZDOTDIR}/misc_zle.zsh
. ${ZDOTDIR}/multiline_enter.zsh
. ${ZDOTDIR}/pacman.zsh
. ${ZDOTDIR}/broot.zsh  # supersedes keys:
                        #   - ctrl+/   (load after completion_and_glob_opts)
                        #   - alt+down (load after clear_and_foldernav)
