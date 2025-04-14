# -------
# General
# -------

setopt promptsubst transientrprompt

autoload -Uz add-zsh-hook

PROMPT2='%B%F{blue}…%f%b '
export PROMPT4='%B%F{white}-- %N:%i %b%f'
PROMPT_EOL_MARK='%F{red} %f'

# -- Simplify on demand --
miniprompt () {
  if (( $+functions[agkozak-zsh-prompt_plugin_unload] )) {
    agkozak-zsh-prompt_plugin_unload
  } elif (( $+functions[powerlevel10k_plugin_unload] )) {
    powerlevel10k_plugin_unload
  }
  PROMPT=$'\n''%B%F{white}-- %F{green}$ %f%b'
  RPROMPT=
  unset VIRTUAL_ENV_DISABLE_PROMPT
}

# ----------------
# Format Functions
# ----------------

# -- Put text in a bubble --
# Sets: REPLY
# -e: add hashes before format ending braces: %F{xxx} -> %F{xxx#}
# --
# If LANG=en_US.UTF-8 is not set,
# or the system locale is not set to en_US.UTF-8,
# the bubble characters may mess up the spacing
# and put the cursor in a weird place.
# To avoid the issue, uncomment the bookends='' line below.
# Also comment out distro_icons entries, lower down.
.zshrc_prompt-bubble () {  # [-e] <content-str>
  emulate -L zsh
  unset REPLY

  local bubble_bg='#1f1f28'
  local bubble_fg=green
  if [[ $1 == -e ]] {
    shift
    bubble_bg="${bubble_bg}#"
    bubble_fg="${bubble_fg}#"
  }

  local bookends
  bookends=''           # powerline extended
  # bookends=''         # powerline
  # bookends=('<<' '>>')  # ASCII
  # bookends=''           # naked

  REPLY="%F{${bubble_bg}}${bookends[1]}%K{${bubble_bg}}%F{${bubble_fg}}${@}%F{${bubble_bg}}%k${bookends[-1]}%f"
}

# -----------------
# Content Functions
# -----------------

# -- git Status --
# Sets: REPLY
.zshrc_prompt-gitstat () {
  emulate -L zsh
  unset REPLY

  if ! (( $+commands[git] ))  return

  vcs_info 2>/dev/null
  if [[ $VCS_INFO_backends ]] {
    if [[ $vcs_info_msg_0_ ]] {
      local gitroot=$(git rev-parse --show-toplevel 2>/dev/null)
      gitroot=${$(realpath --relative-to=. $gitroot 2>/dev/null):#(.|$PWD)}
      REPLY="%F{magenta}${gitroot}%F{white}${gitroot:+:}${vcs_info_msg_0_}"
    }
  } else {
    local gitref=${$(git branch --show-current 2>/dev/null):-$(git rev-parse --short HEAD 2>/dev/null)}

    if [[ $gitref ]] {
      local dirt=$(git status --porcelain 2>/dev/null)

      local gitroot=$(git rev-parse --show-toplevel 2>/dev/null)
      gitroot=${$(realpath --relative-to=. $gitroot 2>/dev/null):#(.|$PWD)}

      REPLY="%F{magenta}${gitroot}%F{white}${gitroot:+:}%F{blue}${gitref}%F{red}${${dirt}:+*}%f"
    }
  }
}

# -- yadm Status --
# Sets: REPLY
.zshrc_prompt-yadmstat () {
  emulate -L zsh
  unset REPLY

  if (( $+commands[yadm] )) {
    local dirt=$(yadm status --porcelain . 2>/dev/null)
    if [[ $dirt ]]  REPLY="%F{red}${${dirt}:+*}%f"
  }
}

# -- tsk Count --
# Sets: REPLY
.zshrc_prompt-tskcount () {
  emulate -L zsh
  unset REPLY

  local lines
  if (( $+commands[tsk] )) {
    lines=(${(f)"$(tsk list 2>/dev/null)"})
    lines=(${lines:#\*No tasks\*})
  }
  if [[ $lines ]] {
    REPLY="%F{yellow}${#lines} %f"
    if [[ $ZSHRC_PAD_ICONS ]]  REPLY+=' '
  }
}

# -- Print time in dozenal format --
.zshrc_prompt-dozenal-time () {
  emulate -L zsh

  local ten=Ŧ lem=Ł

  local h_m=(${(s: :)${(%):-%D{%L %M}}})
  if [[ "$1" && "$2" ]] {
    local user_hour=$1
    (( user_hour %= 12 ))
    h_m=($user_hour $2)
  }

  local hour=${h_m[1]:s/10/$ten/:s/11/$lem/:s/12/0/}
  local -i minute=${h_m[2]}

  local fivers=${$(( minute/5 )):s/10/$ten/:s/11/$lem/}
  local spillover="${$(( minute%5 )):/0}"

  print -r -- "${hour}.${fivers}${spillover:+:}${spillover}"
}
# TODO: when tmux is "empty" there's an extra gap

# -- Craft an RPROMPT string --
# Sets: REPLY
.zshrc_prompt-rprompt () {
  emulate -L zsh -o extendedglob
  zmodload zsh/mapfile

  local usual_host='dimwell' usual_user='andy'

  # -- Time Bubble --
  .zshrc_prompt-bubble '$(.zshrc_prompt-dozenal-time)'  # fun
  # .zshrc_prompt-bubble '%D{%L:%M}'                    # business
  local time_bubble=$REPLY

  # -- Tab Bubbles --
  .zshrc_prompt-bubble -e '#{?#{==:#{pane_tty},$TTY},%F{white#}%U,%F{blue#}}#{?#{!=:#W,zsh},#W,$}#{?#{!=:#{window_panes},1},+,}%u'
  local tmux_bubbles='${(j: :)${(f)"$(tmux lsw -F "'$REPLY'" 2>/dev/null)"}}'

  # -- Distro Bubble --
  local distro lines distro_bubble
  local -A distro_icons=(
    'alpine'              '%F{#0d597f}'
    'arch'                '%F{#1793d1}'
    'debian'              '%F{#A80030}'
    'fedora'              '%F{#50a1d9}'
    'opensuse-tumbleweed' '%F{#73ba25}'
    'pop'                 '%F{#6cc7d2}'  # #faa41a #48b9c7 #6cc7d2
    'ubuntu'              '%F{#E95420}'
    'ultramarine'         '%F{#fdfdff}󱙴'  # #fdfdff #00078f
    # solus:   .
    # cachy: 󰫰  . #01ccff  #00aa87
    # manjaro:   󱘊  .
    # artix:   .
    # archcraft:   .
    # endeavour:   .
    # mint: 󰣭  .
    # mageia:   .
    # mx:   .
    # mandriva:   .
    # parrot:   .
    # peppermint: 󰄊  󱥰    .
    # bsd: 󰱯  󰇴  .
    # void:   .
    # wattos:   .
  )
  lines=(${(f)mapfile[/etc/os-release]})
  distro=${${${(M)lines:#ID=*}##*=\"#}%%\"#}
  if (( $+distro_icons[$distro] )) {
    distro="$distro_icons[$distro]"
    if [[ $ZSHRC_PAD_ICONS ]]  distro+=' '
  }
  .zshrc_prompt-bubble "$distro"
  distro_bubble=$REPLY

  # -- All Segments --
  local right_segments=()
  if [[ $HOST != $usual_host ]] {
    .zshrc_prompt-bubble '%F{blue}%m%f'
    right_segments+=($REPLY)
  }
  if [[ $USERNAME != $usual_user ]] {
    .zshrc_prompt-bubble '%(!.%F{red}%n%f.%F{green}%n%f)'
    right_segments+=($REPLY)
  }
  if [[ $TMUX ]]  right_segments+=($tmux_bubbles)
  right_segments+=($time_bubble)
  right_segments+=($distro_bubble)

  REPLY=${(j: :)right_segments}
  # REPLY='${(P):-'$REPLY'}'
}

# --------------
# Hook Functions
# --------------

# -- Time slow commands --
.zshrc_prompt-timecheck () {
  ZSHRC_PROMPT_PRETIME=$EPOCHREALTIME
}

# -- Populate psvar --
.zshrc_prompt-setpsvar () {
  ZSHRC_PROMPT_RET=$?
  ZSHRC_PROMPT_PIPESTATUS=(${pipestatus})

  emulate -L zsh
  local REPLY
  psvar=()

  if (( ! $+functions[powerlevel10k_plugin_unload] )) {

    # -- retcodes if non-zero --
    local pipestatus_nonzero=(${ZSHRC_PROMPT_PIPESTATUS#0}) pipestatus_color=red
    if [[ ! $pipestatus_nonzero ]] && (( ZSHRC_PROMPT_RET )) {
      ZSHRC_PROMPT_PIPESTATUS=($ZSHRC_PROMPT_RET)
      pipestatus_nonzero=($ZSHRC_PROMPT_RET)
    }
    if [[ $pipestatus_nonzero ]] {
      if [[ ${ZSHRC_PROMPT_PIPESTATUS[-1]} == 0 ]]  pipestatus_color=yellow
      .zshrc_prompt-bubble "%F{$pipestatus_color}${(j:|:)ZSHRC_PROMPT_PIPESTATUS} <-%f"
      psvar+=($REPLY)
    }

    # -- folder --
    .zshrc_prompt-bubble '%B%F{magenta}%~%b'
    psvar+=($REPLY)

    # -- git info --
    .zshrc_prompt-gitstat
    if [[ $REPLY ]] {
      .zshrc_prompt-bubble $REPLY
      psvar+=($REPLY)
    }

    # -- venv --
    if [[ $VIRTUAL_ENV ]] {
      local venv_parent=${VIRTUAL_ENV:h:t}
      if (( #venv_parent > 9 ))  venv_parent=${venv_parent[1,4]}…${venv_parent[-3,-1]}

      .zshrc_prompt-bubble "${venv_parent}/${VIRTUAL_ENV:t}"
      psvar+=($REPLY)
    }

    # -- slow cmd time --
    if [[ $ZSHRC_PROMPT_PRETIME ]] {
      local cmd_duration=$(( EPOCHREALTIME - ZSHRC_PROMPT_PRETIME ))
      unset ZSHRC_PROMPT_PRETIME
      if (( cmd_duration > 1 )) {
        local bigten=$(( cmd_duration * 10 + 0.5 ))
        bigten=${bigten%%.*}
        .zshrc_prompt-bubble ${bigten[1,-2]}.${bigten[-1]}s
        psvar+=($REPLY)
      }
    }

  }

  # -- yadm info --
  # .zshrc_prompt-yadmstat
  # if [[ $REPLY ]] {
  #   .zshrc_prompt-bubble .$REPLY
  #   psvar+=($REPLY)
  # }

  # -- tsk info --
  .zshrc_prompt-tskcount
  if [[ $REPLY ]] {
    .zshrc_prompt-bubble $REPLY
    psvar+=($REPLY)
  }

  # -- mise --
  if [[ $MISE_SHELL ]] {
    local mise_configs=(${(f)"$(mise config ls --no-header)"})
    mise_configs=(${${mise_configs%%  *}/#\~/$HOME})
    mise_configs=(${mise_configs:#$HOME/.config/mise/config.toml})
    for mise_cfg ( $mise_configs ) {
      .zshrc_prompt-bubble $(realpath --relative-to=. $mise_cfg)
      psvar+=($REPLY)
    }
  }

}

# ----------------------------------------------------
# Set up PROMPT and RPROMPT, or agkozak or p10k plugin
# ----------------------------------------------------

if (( ! $+functions[agkozak-zsh-prompt_plugin_unload] ))  add-zsh-hook precmd .zshrc_prompt-setpsvar

# -- Configure p10k if loaded --
if (( $+functions[powerlevel10k_plugin_unload] )) {
  # TODO: add tsk count to p10k and agkozak configs
  if [[ -r ${ZDOTDIR:-${${(%):-%x}:P:h}}/.p10k.zsh ]]  . ${ZDOTDIR:-${${(%):-%x}:P:h}}/.p10k.zsh
  POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='%F{white}%B-- %F{green}$%b%f'
  POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='%F{white}%B-- %F{green}$%b%f'
  POWERLEVEL9K_STATUS_ERROR=true
  POWERLEVEL9K_VIRTUALENV_CONTENT_EXPANSION='${P9K_CONTENT%% *}'
  POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=true
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=( dir vcs my_psvar newline prompt_char )
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(newline status command_execution_time background_jobs virtualenv my_rprompt)
  prompt_my_psvar () { p10k segment -t "${(j: :)psvar}" }
  prompt_my_rprompt () { .zshrc_prompt-rprompt; p10k segment -e -t "$REPLY" }

  # This doesn't seem to work anymore:
  # .zshrc_prompt-bubble '${$((my_git_formatter(1)))+${my_git_format}}'
  # This doesn't quite work either:
  # .zshrc_prompt-bubble '${P9K_CONTENT//\%([FK]\{[^\}]##\}|[fk])/}'
  # POWERLEVEL9K_VCS_CONTENT_EXPANSION=$REPLY

# -- Configure agkozak if loaded --
} elif (( $+functions[agkozak-zsh-prompt_plugin_unload] )) {
  AGKOZAK_USER_HOST_DISPLAY=0
  AGKOZAK_CUSTOM_SYMBOLS=('⇣⇡' '⇣' '⇡' '+' 'D' 'M' '→' '?' '$')
  AGKOZAK_LEFT_PROMPT_ONLY=1
  AGKOZAK_PROMPT_CHAR=('%F{white}%B-- %F{green}$%b%f' '#' ':')
  AGKOZAK_PROMPT_DIRTRIM=4
  AGKOZAK_PROMPT_DIRTRIM_STRING=…
  AGKOZAK_COLORS_PATH=magenta
  AGKOZAK_BLANK_LINES=1

  # -- Piped Command Error Return Codes --
  # https://github.com/agkozak/agkozak-zsh-prompt/issues/34
  .zshrc_prompt-agkozak-pipestatus-hook () {
    AGKOZAK_PIPESTATUS="${${pipestatus#0}:+(${"${pipestatus[*]}"// /|})}"
    if [[ ! $AGKOZAK_PIPESTATUS ]]  return
    if [[ $AGKOZAK_PIPESTATUS == *0\) ]] {
      .zshrc_prompt-bubble "%F{yellow}${AGKOZAK_PIPESTATUS}"
    } else {
      .zshrc_prompt-bubble "%F{red}${AGKOZAK_PIPESTATUS}"
    }
    AGKOZAK_PIPESTATUS=$REPLY
  }
  add-zsh-hook precmd .zshrc_prompt-agkozak-pipestatus-hook

  .zshrc_prompt-rprompt
  AGKOZAK_CUSTOM_RPROMPT="\${AGKOZAK_PIPESTATUS} $REPLY"

# -- Set PROMPT and RPROMPT if no prompt plugin is loaded --
} else {
  VIRTUAL_ENV_DISABLE_PROMPT=1

  autoload -Uz vcs_info
  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:*' unstagedstr '*'
  zstyle ':vcs_info:*' stagedstr '*'
  zstyle ':vcs_info:git*' formats '%F{blue}%b%F{red}%u%c%f'
  zstyle ':vcs_info:git*' actionformats '%F{blue}%b%F{yellow}|%a%F{red}%u%c%f'

  add-zsh-hook preexec .zshrc_prompt-timecheck
  PROMPT=$'\n''${(j: :)psvar}'$'\n''%B%F{white}-- %F{green}%(!.#.$)%f%b '

  .zshrc_prompt-rprompt
  RPROMPT=$REPLY
}
