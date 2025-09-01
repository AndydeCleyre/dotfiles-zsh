alias x="ouch decompress"
# TODO: fallbacks for x

# systemd.zsh:
alias sc="systemctl"
alias scu="systemctl --user"

alias rsync-copy="rsync -hhh --archive --checksum --info=progress2 --partial --xattrs"

# -- Strip leading tai64n timestamps and non json-line lines --
jlines () { grep -E '@[^ ]+ \{' | sed -E 's/^[^ ]+ //g' }
# fac -s '[ R/ ^@[^ ]+ .*/ matches? ] [ R/ ^@[^ ]+ / "" re-replace ] filter-map'

if (( $+commands[wget] )) {
  alias get="wget"
} else {
  alias get="curl -LO"
}

# -- run mise tasks --
alias t="mise run"

alias yy="paru && mise up --bump && pipz upgrade --all && DIFFPROG=meld MERGEPROG=meld pacdiff -3 -s"

# -- Invoke Factor in a pipe-friendly way --
# Depends: Factor
# Optional: h (paging_and_printing.zsh)
# Options:
#  -l: map code to each line
#  -s: split lines into a sequence
#  -j: parse input as JSON
#  -j: parse input as JSON Lines
#  -y: parse input as YAML
#  -d: debug (show Factor code)
# Examples:
#   fac -l '>upper " is an uppercase line" append'
#   fac -s 'length I"${} lines"'
#   fac 'length I"${} characters"'
fac () {  # [-(l|s|j|J|y)] [-d] <factor-code>...
  emulate -L zsh

  local usage=(
    'fac: Invoke Factor in a pipe-friendly way' ''
    'Usage:' '' '  fac [-(l|s|j|J|y)] [-d] <factor-code>...' ''
    'Options:' ''
    '  -l    map code to each line'
    '  -s    split lines into a sequence'
    '  -j    parse input as JSON'
    '  -j    parse input as JSON Lines'
    '  -y    parse input as YAML'
    '  -d    debug (show Factor code)' ''
    'Examples:' ''
    '  fac -l '"'"'>upper " is an uppercase line" append'"'"
    '  fac -s '"'"'length I"${} lines"'"'"
    '  fac '"'"'length I"${} characters"'"'"
  )

  local cmd=factor
  if (( $+commands[factor-vm] ))  cmd=factor-vm

  local eachline splitlines onestring debug parsejson parseyaml parsejsonlines
  while [[ $1 == -[lsjJyd] ]] {
    case $1 {
      (-l)  eachline=1        ;;
      (-s)  splitlines=1      ;;
      (-j)  parsejson=1       ;;
      (-J)  parsejsonlines=1  ;;
      (-y)  parseyaml=1       ;;
      (-d)  debug=1
    }
    shift
  }

  if [[ $1 == -* ]] {
    print -rlu2 -- ${(F)usage}
    return 1
  }

  if [[ $parsejson || $parseyaml || $parsejsonlines ]] {
    eachline=
    splitlines=
  }
  if [[ $eachline ]]  splitlines=1
  if ! [[ $eachline || $splitlines ]]  onestring=1

  if [[ -t 0 ]] {
    eachline=
    splitlines=
    onestring=
    parsejson=
    parsejsonlines=
    parseyaml=
  }

  local factorcode="
    auto-use
    USING: splitting unicode ;
    IN: scratch

    : cli-print ( x -- )
      {
        { [ dup string?   ] [ print                   ] }
        { [ dup boolean?  ] [ .                       ] }
        { [ dup sequence? ] [ [ cli-print ] each      ] }
        { [ dup assoc?    ] [ USE: json write-json nl ] }
        [ . ]
      } cond ;

    ${splitlines:+read-lines}
    ${eachline:+[}
    ${onestring:+read-contents}

    ${parsejson:+USE: json json>}
    ${parsejsonlines:+USE: json jsonlines>}
    ${parseyaml:+USE: yaml yaml>}

    ${${${(j: :)@}/ >json/ USE: json >json}/ >yaml/ USE: yaml >yaml}

    ${eachline:+] map }

    cli-print
  "

  if [[ $debug ]] {
    if (( $+functions[h] )) {
      print -rlu2 -- "-- Start Factor Code --"
      h -s factor <<<$factorcode >&2
      print -rlu2 -- "-- End Factor Code --" ''
    } else {
      print -rlu2 -- "-- Start Factor Code --" $factorcode "-- End Factor Code --" ''
    }
  }

  $cmd -no-user-init -e=$factorcode
}

# TODO: title/prompt
# -- Pick from a list of choices --
# Sets REPLY, unless -m is passed for multi-choice, and reply is set instead
# Depends: (for -m support) gum, skim, OR fzf
zpick () {  # [-m] <choice>...
  emulate -L zsh
  unset REPLY reply

  local fzf_opts=(--layout=reverse-list)
  local sk_opts=(--bind='ctrl-q:abort')

  if [[ $1 == -m ]] {
    shift
    fzf_opts+=(--multi)

    if (( $+commands[gum] )) {
      reply=(${(f)"$(gum choose --no-limit $@)"})
    } elif (( $+commands[sk] )) {
      reply=(${(f)"$(<<<"${(F)@}" sk $fzf_opts $sk_opts)"})
    } elif (( $+commands[fzf] )) {
      reply=(${(f)"$(<<<"${(F)@}" fzf $fzf_opts)"})
    } else {
      print -ru2 "UNIMPLEMENTED without fzf, sk, or gum"
      return 1
    }
  } else {
    if (( $+commands[gum] )) {
      REPLY=$(gum choose $@)
    } elif (( $+commands[sk] )) {
      REPLY=$(<<<"${(F)@}" sk $fzf_opts $sk_opts)
    } elif (( $+commands[fzf] )) {
      REPLY=$(<<<"${(F)@}" fzf $fzf_opts)
    } else {
      local answer
      select answer ( $@ ) { break }
      REPLY=$answer
    }
  }
}

# -- playdelete: Play videos, then ask to delete them --
# Depends: mpv
# Optional:
#   - zpick (unsorted_functions.zsh)
#   - broot
#   - trash-cli (PyPI)
pd () {  # [<vid>...]
  emulate -L zsh -o extendedglob -o globdots -o globstarshort -o errreturn
  zmodload -F zsh/stat b:zstat

  local exts=(avi flv m4v mkv mp4 webm wmv)

  local trashcmd=(trash)
  if ! (( $+commands[trash] ))  trashcmd=(=rm -i)

  local brootcmd=(broot)
  if ! (( $+commands[broot] )) {
    brootcmd=
  } elif (( $+functions[br] )) {
    brootcmd=(br)
  }

  local choices=(Next Quit DELETE Replay)
  if [[ $brootcmd ]]  choices=(Next Quit DELETE Broot Replay)

  local -U vids=()
  if ! [[ $1 ]] {
    vids=( (#i)***.(${(j:|:)~exts})(.) )
  } else {
    for 1 {
      if [[ -d $1 ]] {
        vids+=( $1/***.(#i)(${(j:|:)~exts})(.) )
      } else {
        vids+=($1)
      }
    }
  }
  vids=(${vids:a})

  local vid REPLY reply do_play
  for vid ( ${(f)"$(<<<${(F)vids} shuf)"} ) {
    do_play=1
    while [[ $do_play ]] {
      do_play=

      print -rl -- '--' "-- Playing $vid --"

      zstat +size -A reply $vid
      print -rn -- '-- '
      print -rlf %.2f $(( reply / 1048576. ))
      print -r -- ' MiB --'

      mpv --no-terminal $vid

      unset REPLY
      if (( $+functions[zpick] )) {
        while [[ $REPLY != (Next|Quit|DELETE|Broot|Replay) ]]  zpick $choices
      } else {
        local answer
        while [[ $REPLY != (Next|Quit|DELETE|Broot|Replay) ]] {
          select answer ( $choices ) { break }
          REPLY=$answer
        }
      }
      case $REPLY {
        (Next)    print -- '-- Moving on --' ;;
        (Quit)    return ;;
        (DELETE)  $trashcmd $vid ;;
        (Broot)   br $vid:a:h -c ":show $vid:t" ;;
        (Replay)  do_play=1
      }
    }
  }
}

# -- Completion Help Messages --
# Depends: .zshrc_help_complete (help.zsh)
if (( $+functions[.zshrc_help_complete] ))  .zshrc_help_complete fac pd zpick
