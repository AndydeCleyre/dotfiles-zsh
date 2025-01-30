# -- Old junk, some of which might be worth resurrecting eventually --
# Not sourced


insist () { while ! { $@ }  $@ }

alias aw="wiki-search"

alias ddg="ddgr -n 3 -x --show-browser-logs"
alias ggl="googler --show-browser-logs -x -n 6"

log () {  # <key> <val> [<key> <val>]...
  emulate -L zsh
  local k v pairs=()
  for k v ( $@ )  pairs+=("${k}: ${v}")
  print -rlu2 -- "-- ${(j: -- :)pairs} --"
}

# TODO: s6.zsh ?
logrun () {  # <cmd> [<cmd-arg>...]
  emulate -L zsh
  # if [[ ! $1 ]] || [[ $1 =~ '^-(-help|h)$' ]] {
  if [[ $1 =~ '^(-(-help|h))?$' ]] {
    print -u2 'logrun <cmd> [<cmd-arg>...]'
    return 1
  }
  local logdir=$PWD/$1.${(%):-%D{%Y-%m-%d-%s}}.log.d
  print -ru2 -- "-- Logging to $logdir/current"
  $@ |& s6-log T s4194304 S41943040 $logdir
}
logit () {  # [logdir]
  emulate -L zsh
  local logdir=${${:-${1:-$PWD}/${(%):-%D{%Y-%m-%d-%s}}.log.d}:a}
  print -ru2 -- "-- Logging to $logdir/current"
  s6-log T s4194304 S41943040 $logdir
}

newage () {
  emulate -L zsh
  mkdir -p ~/.config/sops/age
  print -rl "# --- ${1:-$(date +"%Y-%m-%d %H:%M:%S%Z")} ---" >>~/.config/sops/age/keys.txt
  age-keygen >>~/.config/sops/age/keys.txt
}

# video.zsh? av.zsh?

tsplit () {  # <file>...
    emulate -L zsh
    zmodload -F zsh/stat b:zstat

    local reply
    for 1 {
        zstat -A reply +size $1
        if (( reply > 2097152000 )) {
            7z a -mx0 -v2000m "${1:t:r}.7z" $1
        } else {
            print -ru 2 -- "Skipping small-enough $1"
        }
        # TODO: more precisely max out the sizes
    }
}
vidcut () {  # sourcevid start [end]
    local end=${3:-$(ffprobe -v -8 -show_entries format=duration -of csv=p=0 $1)}
    local vidname="${1:r}--cut-${2//:/_}-${end//:/_}.${1:e}"
    ffmpeg -i "$1" -ss "$2" -to "$end" -c copy -map 0 "$vidname" || \
    ffmpeg -i "$1" -ss "$2" -to "$end" -c copy "$vidname"
}
vidgif () {  # sourcevid [gif-filename]
    ffmpeg -i $1 -vf "fps=10,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" ${2:-${1:r}.gif}
}
vidtg () {  # sourcevid [video-encoder=copy [audo-encoder=copy]]
# TODO: fzf multi-choosing streams and codecs
  local vidname="${1:r}--tg.mp4"
    # ffmpeg -i "$1" -an -c:v libx264 "$vidname"
    # ffmpeg -i "$1" -an -c:v libx264 "$vidname"
  ffmpeg \
    -i "$1" \
    -c:v "${2:-copy}" \
    -c:a "${3:-copy}" \
    -c:s mov_text \
    -movflags +faststart \
    "$vidname"
    # -map 0 \
}
voices () {  # [text]
    for voice in ${(z)"$(mimic -lv)"#*: }; do
        print "Testing voice: $voice . . ."
        mimic -t "$1; This voice is called $voice" -voice $voice \
        || print "%F{red}ERROR testing $voice%f"
    done
}
say () {  # <text...>
    mimic -voice awb -t "${(j: :)@}"
}
alias xdn="xargs -d '\n'"

cleansubs () {  # [<srt file>...]
  emulate -L zsh

  local srts=(${@:-*.srt})
  [[ $srts ]] || return 1

  local patterns=(
    '^Advertise your prod.*'
    '^Support us and become.*'
    '.*OpenSub.*'
    '.*Please rate this subtitle.*'
    '.*choose the best subtitles*'
    '\[[^]]+\]'
    '\([^)]+\)'
    '♪.*'
    '.*♪'
  )

  for pattern ( $patterns ) {
    if { rg -S -C 2 $pattern $srts } {
      if { read -q "?Delete matches [yN]? " } {
        sed -i -E "s/${pattern}//g" $srts
      }
      print '\n'
    }
  }
}

pw () {  # [<filter-word>...]
  emulate -L zsh
  rbw login
  local fzf_args=(--reverse -0)
  if [[ $1 ]]  fzf_args+=(-q "${(j: :)@}")
  # rbw get "$(rbw ls | fzf $fzf_args)" | xclip -sel clip
  local lines=(${(f)"$(rbw get --full "$(rbw ls | fzf $fzf_args)")"})
  xclip -sel clip <<<${lines[2]##Username: }
  xclip -sel clip <<<${lines[1]}
}

x () {  # <archive>
  emulate -L zsh
  rehash

  local first_choice new_folder
  local -i count ret

  for 1 {

    # TODO: .tar.gz should be treated as one suffix... what else?
    if [[ $1:t:r ]] {
      first_choice=${1:a:r}
    } else {
      first_choice=${1:a}.contents
    }

    # local new_folder=$first_choice
    # local -i count=0
    new_folder=$first_choice
    count=0
    while [[ -e $new_folder ]] {
      new_folder=${first_choice}.${count}
      count+=1
    }

    if (( $+commands[notify-send] ))  {
      notify-send -i ark -a Extracting "${1:t}" "$new_folder" || true
    }

    mkdir $new_folder

    if (( $+commands[7zz] )) {
      7zz x "-o${new_folder}" $1
    } elif (( $+commands[7z] )) {
      7z x "-o${new_folder}" $1
    } elif (( $+commands[aunpack] )) {
      aunpack -X "$new_folder" $1
    } elif (( $+commands[ark] )) {
      ark -b -o "$new_folder" $1
    } elif (( $+commands[tar] )) {
      tar xf $1 -C "$new_folder"
    } else {
      print -rPu2 "%F{red}No suitable unarchiver detected!%f"
      return 1
    }
    ret=$?

    print -ru2 Destination: $new_folder

    if (( $+commands[notify-send] )) {
      notify-send -i ark -a "Finished Extracting" "${${ret:#0}:+[ERROR $ret] }${1:t}" "$new_folder" || true
    }
    return ret
  }
}

# -- awk --
.zshrc_numth () {  # <num> [delimiter [filter-regex]]
  awk -F ${2:- } '/'"${3:-.*}"'/ {print $'"$1"'}'
}
1st () { .zshrc_numth 1 $@ }  # [delimiter [filter-regex]]
2nd () { .zshrc_numth 2 $@ }  # [delimiter [filter-regex]]
3rd () { .zshrc_numth 3 $@ }  # [delimiter [filter-regex]]
for num ( {4..20} )  eval "${num}th () { .zshrc_numth $num \$@ }"
last () { awk -F ${1:- } '/'"${2:-.*}"'/ {print $NF}' }  # [delimiter [filter-regex]]

# -- buildah --
alias bld="buildah"
alias bldc="buildah containers"
alias bldi="buildah images"
alias docker="podman"

bldi-rmnone () { buildah rmi $(buildah images -f dangling=true --format '{{.ID}}') }

bldimg () {
  emulate -L zsh

  local data=$(mktemp)
  trap "rm -rf ${(q-)data}" EXIT INT QUIT
  buildah images --json >"$data"

  local image_ids
  image_ids=($(yaml-get -p .id "$data"))

  local rows=() row=() img_id
  local -U names=()
  for img_id ( $image_ids ) {
    IFS=${IFS}:
    names=(${=$(buildah images --json | yaml-get -p "[id=$img_id].names.*")})
    IFS=$IFS[1,-2]
    # row=(
    #   "$img_id"
    #   "$(yaml-get -p "[id=$img_id].createdat" "$data")"
    #   "$(yaml-get -p "[id=$img_id].size" "$data")"
    #   "${(j. :: .)names}"
    # )
    row=(
      "${names[1]}"
      "$img_id"
      "$(yaml-get -p "[id=$img_id].createdat" "$data")"
      "$(yaml-get -p "[id=$img_id].size" "$data")"
      "[${(j:, :)names[2,-1]}]"
    )
    rows+=("${(j. | .)row}")
  }

  # print -rn -- "${$(<<<${(F)rows} fzf --reverse -m -0)%% *}"
  <<<${(F)rows} fzf --reverse -m -0 | cut -d ' ' -f 3
}


# --- #

# If ctnr <cname> exists, do nothing. Otherwise create it from <iname>.
.buildah_require_ctnr () {  # <cname> [iname=alpine:3.11]
    buildah inspect $1 &>/dev/null \
    || buildah from --name $1 ${2:-alpine:3.11}
}

# Interactively select a local ctnr, printing its name.
.buildah_pick_ctnr () {
    setopt localoptions extendedglob
    print -rn "${$(
        buildah containers --format '{{.ContainerName}} :: {{.ImageName}}' \
        | fzf --reverse -0 -1
    )%% ##:: *}"
    # )% :: *}"  # https://github.com/containers/buildah/issues/2016
}

# Interactively select a local image, printing its name.
.buildah_pick_img () {
    # print -rn "${$(buildah images --format '{{.Name}} :: {{.Tag}} :: {{.Size}} :: {{.ID}}' | fzf --reverse -0 -1
    setopt localoptions extendedglob
    print -rn "${$(
        buildah images --format '{{.Name}} :: {{.Tag}} :: {{.ID}} :: {{.Size}} :: {{.CreatedAt}}' \
        | fzf --reverse -0 -1
    )%% ##

# -- pacman --
#
alias spacman="sudo pacman"
alias update-mirrors="sudo reflector --save /etc/pacman.d/mirrorlist --sort score --country 'United States' --country 'Canada' --latest 30 -p http"
alias yc="sudo DIFFPROG='sudo -u andy env SUDO_EDITOR=meld sudoedit' pacdiff"

why () {  # <pkgname...>
    for 1; {
        pactree -r $1
        pacman -Qi $1 \
        | grep -E '^Description\s+:' \
        | sed -E 's/[^:]+:\s+(.+)/\1/'
    }
}

alias whose="pacman -Qo"

when () {  # <pkgname-filter>
    ((( $+commands[rainbow] )) &&
        grep -aEi "ed [^ ]*$1" /var/log/pacman.log \
        | rainbow \
            --bold '(?<=^\[\d{4}-)\d{2}-\d{2}' \
            --blue reinstalled \
            --green installed \
            --yellow upgraded \
            --red removed \
            --bold '[^ \(]+(?=\)$)' \
            --bold '(?<='$1')\S+' \
            --bold '\S+(?='$1')' \
            --italic $1
    ) ||
        grep -aEi "ed [^ ]*$1" /var/log/pacman.log
}
            # --bold '(?<= -> )[^ ]+(?=\)$)' \

# alias what="pactree -c"

where () {  # pkgname
    (pacman -Qql "$@" || pkgfile -lq "$@") | grep -P -v "/$"
}
# alias what="where"

if type compdef &>/dev/null; then

    _why () { _alternative "arguments:Installed Packages:($(pacman -Qq))" }
    compdef _why why

    _whose () { _alternative 'arguments:Files:_files' 'arguments:Commands:_files -W /bin' }
    compdef _whose whose

    _when () {
        local repos=($(pacman-conf --repo-list) AUR)
        _arguments '1:All Packages:(${$(yay -Pc):|repos})'
    }
    compdef _when when yg

    _where () { _alternative 'arguments:All Packages:_pacman_completions_all_packages' }
    compdef _where where

fi

# -- s6/essex --
alias sussex="sudo essex -d /var/svcs"
alias tin="s6-tai64n"
alias tout="s6-tai64nlocal"
_essex () {
    local cmds=(cat disable enable list log new off on pid print pt reload sig start status stop sync tree upgrade)
    local svc_cmds=(cat disable enable log pid print reload sig start status stop sync upgrade)
    local sigs=(alrm abrt quit hup kill term int usr1 usr2 stop cont winch)
    local folder_options=(-d --directory -l --logs-directory)
    local svcs_dir=$HOME/svcs
    local cmd_idx=2
    # TODO: properly handle options/subcmds (differently, and with menu-descriptions)...
    # TODO: maybe template this as a file with pyratemp
    # TODO: add more completions, obviously
    # TODO: _normal for cmd
    # TODO: e.g. stop fumbles over newline-"excludes..."
    while (( ${folder_options[(I)${words[cmd_idx]}]} )); do
        cmd_idx=$(( cmd_idx+2 ))
    done
    if (( ${svc_cmds[(I)${words[$cmd_idx]}]} )); then
        local subcmd=${words[$cmd_idx]}
        if [[ $subcmd == sig ]]; then
            _arguments \
                "$(( cmd_idx-1 )):Commands:($cmds)" \
                "$cmd_idx:Signals:($sigs)" \
                "*:Services:($svcs_dir/[^.]*(/:t))"
        else
            _arguments \
                "$(( cmd_idx-1 )):Commands:($cmds)" \
                "*:Services:($svcs_dir/[^.]*(/:t))"
        fi
        _message "$(
            essex $subcmd --help \
            | tail -n +3 \
            | grep -Ev '^Meta-switches:|^Usage:|^\s+(-|excludes -)|^$'
        )"
    else
        _arguments \
            "1:Commands:($cmds)"
    fi
}
if type compdef &>/dev/null; then
  compdef _essex essex
fi

# -- systemd --
() {
  emulate -L zsh
  for 1 ( start stop restart enable disable mask daemon-reload ) alias sc-$1="sudo systemctl $1"
  # TODO: is this needed anymore, or does systemctl assist in priv elevation?
}
alias sc-status="systemctl status"
alias scu="systemctl --user"
# alias sc-list-enabled="systemctl list-unit-files --no-pager | grep enabled"
alias sc-list-enabled="jc systemctl list-unit-files | yaml-get -p '.[state = enabled].unit_file'"


# -- Generate PNG --
# Depends: freeze or silicon
codepic () {  # -s <syntax>
  emulate -L zsh

  local output=code.png

  if [[ -e $output ]] {
    print -rlu2 "Overwrite ${output}? "
    if ! { read -q }  return
  }

  # TODO: freeze: if piped in, demand syntax (avoid xdg-open)
  # TODO: use clipboard if not piped and no file args
  # TODO: silicon fallback

  argv=(${argv:/-s/--language})
  =freeze \
    --border.radius 8 \
    --font.family 'Iosevka Term Custom' \
    --font.ligatures \
    --padding 10,0,10,10 \
    --show-line-numbers \
    --theme catppuccin-mocha \
    --output $output \
    $@ &>/dev/null

    # silicon \
    #   -o ${font}.png \
    #   -l $syntax \
    #   --theme Coldark-Dark \
    #   --pad-horiz 20 \
    #   --pad-vert 25 \
    #   --shadow-blur-radius 5 \
    #   --background-image ~/Code/colorcodebot/app/sharon-mccutcheon-33xSu0EWgP4-unsplash.jpg \
    #   -f "${font}=${size}" \
    #   --from-clipboard



  xdg-open $output
}

