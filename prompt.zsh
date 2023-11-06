# TODO:
#   - bubbled folder in agkozak
#   - underlined folder in agkozak

setopt promptsubst transientrprompt

PROMPT2='%B%F{blue}…%f%b '

# -- Bubble String --
# Sets: REPLY
# -e adds hashes before format ending braces: %F{xxx} -> %F{xxx#}
# If LANG=en_US.UTF-8 is not set,
# or the system locale is not set to en_US.UTF-8,
# the bubble characters may mess up the spacing
# and put the cursor in a weird place.
# To avoid the issue, uncomment the bookends='[]' line below.
.zshrc_prompt-bubble () {  # [-e] <content-str>
  emulate -L zsh
  unset REPLY

  local bubble_bg='#16161d'
  local bubble_fg=green
  if [[ $1 == -e ]] {
    shift
    bubble_bg="${bubble_bg}#"
    bubble_fg="${bubble_fg}#"
  }

  local bookends=''
  # bookends='[]'

  REPLY="%F{${bubble_bg}}${bookends[1]}%K{${bubble_bg}}%F{${bubble_fg}}${@}%F{${bubble_bg}}%k${bookends[-1]}%f"
}


() {
  emulate -L zsh
  local REPLY

  local usual_host='pop-os' usual_user='andy'

  # -- Time Bubble --
  .zshrc_prompt-bubble '$(dozenal_time)'  # fun
  # .zshrc_prompt-bubble '%D{%L:%M}'      # business
  local ptime_bubble=$REPLY

  # -- Tab Bubbles --
  .zshrc_prompt-bubble -e '#{?#{==:#{pane_tty},$TTY},%F{white#},%F{blue#}}#{?#{!=:#W,zsh},#W,$}#{?#{!=:#{window_panes},1},+,}'
  local tmux_bubbles='${(j: :)${(f)"$(tmux lsw -F "'$REPLY'" 2>/dev/null)"}}'

  # -- Distro Bubble --
  local distro line distro_bubble
  local -A distro_icons=(
    'Alpine Linux' ''
    'Arch Linux' ''
    'Debian GNU/Linux 12 (bookworm)' ''
    'Fedora Linux' ''
    'Pop!_OS' ''
    'Ubuntu 22.04.3 LTS' ''
  )
  read line </etc/os-release
  distro=${${${line#*=}#*\"}%\"*}  # 🤞
  if (( $+distro_icons[$distro] ))  distro=$distro_icons[$distro]
  .zshrc_prompt-bubble "$distro "
  distro_bubble=$REPLY

  # -- Configure p10k if loaded --
  if (( $+functions[powerlevel10k_plugin_unload] )) {

    if [[ -r ~/.config/zsh/.p10k.zsh ]]  . ~/.config/zsh/.p10k.zsh
    POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='$'
    POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='$'

  # -- Configure agkozak if loaded --
  } elif (( $+functions[agkozak-zsh-prompt_plugin_unload] )) {

    if [[ $HOST == $usual_host && $USERNAME == $usual_user ]]  AGKOZAK_USER_HOST_DISPLAY=0
    AGKOZAK_CUSTOM_SYMBOLS=('⇣⇡' '⇣' '⇡' '+' 'D' 'M' '→' '?' '$')
    AGKOZAK_LEFT_PROMPT_ONLY=1
    AGKOZAK_PROMPT_CHAR=('%F{green}%B$%b%f' '#' ':')
    AGKOZAK_PROMPT_DIRTRIM=4
    AGKOZAK_PROMPT_DIRTRIM_STRING=…
    AGKOZAK_COLORS_PATH=magenta
    AGKOZAK_BLANK_LINES=1

    # -- Piped Command Error Return Codes --
    # https://github.com/agkozak/agkozak-zsh-prompt/issues/34
    .agkozak_pipestatus_hook () {
      AGKOZAK_PIPESTATUS="${${pipestatus#0}:+(${"${pipestatus[*]}"// /|})}"
      if [[ ! $AGKOZAK_PIPESTATUS ]]  return
      if [[ $AGKOZAK_PIPESTATUS == *0\) ]] {
        .zshrc_prompt-bubble "%F{yellow}${AGKOZAK_PIPESTATUS}"
        AGKOZAK_PIPESTATUS="$REPLY "
      } else {
        .zshrc_prompt-bubble "%F{red\}${AGKOZAK_PIPESTATUS}"
        AGKOZAK_PIPESTATUS="$REPLY "
      }
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd .agkozak_pipestatus_hook

    # -- RPROMPT --
    AGKOZAK_CUSTOM_RPROMPT="${distro_bubble} ${ptime_bubble}"
    if [[ $TMUX ]]  AGKOZAK_CUSTOM_RPROMPT="${tmux_bubbles} ${AGKOZAK_CUSTOM_RPROMPT}"
    AGKOZAK_CUSTOM_RPROMPT="\${AGKOZAK_PIPESTATUS}${AGKOZAK_CUSTOM_RPROMPT}"

  # -- Set PROMPT and RPROMPT if no prompt plugin is loaded --
  } else {

    # -- git Status --
    .zshrc_prompt-gitstat () {
      emulate -L zsh

      local gitref=${$(git branch --show-current 2>/dev/null):-$(git rev-parse --short HEAD 2>/dev/null)}
      local gitroot=$(git rev-parse --show-toplevel 2>/dev/null)
      gitroot=${$(realpath --relative-to=. $gitroot 2>/dev/null):#(.|$PWD)}
      print -rP -- "%F{magenta}${gitroot}%F{white}${gitroot:+:}%F{blue}${gitref}%F{red}${$(git status --porcelain 2>/dev/null):+*}%f"
    }

    # -- PROMPT --
    local segments=()
    segments+='${${pipestatus#0}:+%U%F{red\}${(j:|:)pipestatus} <-%f%u }'            # retcodes if non-zero
    .zshrc_prompt-bubble '%B%F{magenta}%U%~%u%b'
    segments+="$REPLY "                                                              # folder
    segments+='%U$(.zshrc_prompt-gitstat)%u${$(git rev-parse HEAD 2>/dev/null):+ }'  # git info
    segments+=$'\n''%B%F{green}%(!.#.$)%f%b '                                        # prompt symbol

    PROMPT=${(j::)segments}

    # -- RPROMPT --
    local right_segments=()
    if [[ $HOST     != $usual_host ]]  right_segments+=('%F{blue}%m%f')
    if [[ $USERNAME != $usual_user ]]  right_segments+=('%(!.%F{red}%n%f.%F{green}%n%f)')
    if [[ $TMUX ]]                     right_segments+=($tmux_bubbles)
    right_segments+=($distro_bubble)
    right_segments+=($ptime_bubble)

    RPROMPT=${(j: :)right_segments}

  }
}

miniprompt () {
  if (( $+functions[agkozak-zsh-prompt_plugin_unload] )) {
    agkozak-zsh-prompt_plugin_unload
  } elif (( $+functions[powerlevel10k_plugin_unload] )) {
    powerlevel10k_plugin_unload
  }
  PROMPT='%F{green}$ %f'
}

dozenal_time () {
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
