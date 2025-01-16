# -- yazi --
# Trying out a bit, until broot implements: https://github.com/Canop/broot/issues/971
yz () {
  emulate -L zsh
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi $@ --cwd-file="$tmp"
  if cwd="$(=cat -- "$tmp")" && [[ "$cwd" ]] && [[ "$cwd" != "$PWD" ]] {
    cd -- "$cwd"
  }
  =rm -f -- "$tmp"
}

# -- Invoke Factor in a pipe-friendly way --
# Depends: Factor
# Example:
#   print -rl -- one two three | fac '[ >upper print ]' each-line
fac () { factor -e="USING: unicode ; ${(j: :)@}" }

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
