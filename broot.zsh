if (( $+commands[broot] )) {  # Without broot, skip this file

# ------
# Basics
# ------

zmodload zsh/mapfile

# -- Run broot, cd into pathfile if successful --
# Depends: zsh/mapfile
br () {  # [<broot-opt>...]
  emulate -L zsh -o localtraps

  local pathfile=$(mktemp)
  trap "=rm ${(q-)pathfile}" EXIT INT QUIT

  if { broot --verb-output "$pathfile" --listen-auto $@ } {
    if [[ -r $pathfile ]] {
      local folder=${mapfile[$pathfile]}
      if [[ $folder ]]  cd $folder
    }
  } else {
    return
  }
}

# -- Clear line, run broot, restore line --
# Key: ctrl+b
# Depends: br
.zle::broot () {
  zle .push-input
  BUFFER="br"
  zle .accept-line
}
zle -N       .zle::broot
bindkey '^b' .zle::broot  # ctrl+b

# ----------------
# Fancy Selections
# ----------------

# -- Select files with broot and print each on a line --
# Depends: ~/.config/broot/select.hjson ( https://github.com/AndydeCleyre/dotfiles-broot )
broot-print-files () {  # [broot-arg...]
  emulate -L zsh
  broot \
    --conf "${XDG_CONFIG_HOME:-${HOME}/.config}/broot/select.hjson;${XDG_CONFIG_HOME:-${HOME}/.config}/broot/conf.hjson" \
    --color yes \
    --git-ignored \
    --no-sizes \
    $@
}

# -- Select a single folder with broot and print it --
# Depends: ~/.config/broot/select-folder.hjson ( https://github.com/AndydeCleyre/dotfiles-broot )
broot-print-folder () {  # [broot-arg...]
  emulate -L zsh
  broot \
    --conf "${XDG_CONFIG_HOME:-${HOME}/.config}/broot/select-folder.hjson;${XDG_CONFIG_HOME:-${HOME}/.config}/broot/conf.hjson" \
    --color yes \
    --git-ignored \
    --only-folders \
    $@
}

# -- Folder Navigation: Down --
# Key: alt+down
# Depends: broot-print-folder
# Optional: .zle::redraw-prompt (prompt_redraw.zsh)
.zle::cd-broot () {
  echoti rmkx
  cd "$(<$TTY broot-print-folder)"
  if (( $+functions[.zle::redraw-prompt] ))  zle .zle::redraw-prompt
  if (( $+functions[_zsh_highlight]      ))  _zsh_highlight
}
zle -N            .zle::cd-broot
bindkey '^[[1;3B' .zle::cd-broot  # alt+down

# -- Start writing a for loop over broot-selected paths (each is $f) --
# Key: esc, f
# Depends: broot-print-files
.zle::for-broot () {
  zle .push-input
  LBUFFER='for f ( ${(f)"$(broot-print-files)"} ) {'$'\n''  '
  RBUFFER=' $f'$'\n''}'
  if (( $+functions[_zsh_highlight] ))  _zsh_highlight
}
zle -N        .zle::for-broot
bindkey '\ef' .zle::for-broot  # esc, f

# -- Complete current word as path using broot --
# Key: ctrl+/
# Depends: broot-print-files
.zle::insert-path-broot () {
  setopt localoptions extendedglob localtraps

  # In case the user aborts with alt-enter, be ready to change folder
  local pathfile=$(mktemp)
  trap "=rm ${(q-)pathfile}" EXIT INT QUIT
  local broot_args=(--verb-output $pathfile)

  # If the current word is partially typed, grab it (partial),
  # pop it off the line, and create a search string for it (broot_search)
  local partial broot_search
  if [[ ${LBUFFER[-1]/ } ]] {

    # Store it (partial)
    partial=(${(z)LBUFFER})
    partial=${partial[-1]}

    # Remove it from the line
    LBUFFER=${LBUFFER[1,-$#partial-1]}

    # Expand home folder
    partial=${partial/#(\$HOME\/|\~\/)/~\/}

    # Store a sanitized version for broot search (broot_search)
    broot_search=${partial/#~\/}                          # strip leading '~/'
    broot_search=${broot_search//( |:|..\/|\;|\\|\'|\")}  # strip ' ', ':', '../', ';', '\', "'", '"'
    broot_search=${broot_search//.\/}                     # strip './'
    broot_search=${broot_search//\//\\/}                  # replace '/' with '\/'

  }

  # If resulting search string starts with '.' or ends with '/.',
  # search hidden files (can be slow)
  local show_hidden=--no-hidden
  if [[ $broot_search[1] == . || $broot_search[-2,-1] == /. ]]  show_hidden=--hidden

  # If partial has leading '/', '../', or ~/,
  # set broot start folder (start_dir)
  local start_dir
  if [[ $partial == ~/* ]] {
    start_dir=~
  } else {
    local updirs=${(M)partial##(../|/)##}
    start_dir=${updirs:-.}
  }

  # Collect determined broot arguments
  broot_args+=($show_hidden $start_dir)
  if [[ $broot_search ]]  broot_args+=(--cmd "$broot_search")

  # Get a location (or not) from broot,
  # using select.hjson config
  echoti rmkx
  local locations=(${(f)"$(<$TTY broot-print-files $broot_args)"})

  # Add location to line or restore original partial
  if [[ $locations ]] {

    # If GNU coreutils realpath is present,
    # convert some paths from absolute to relative
    if (( $+commands[realpath] )) {
      if [[ $(realpath --help 2>&1) == *--relative-base* ]] {
        local locations_abs=($locations) loc
        locations=()
        for loc ( $locations_abs )  locations+=("$(realpath --relative-base ~ --relative-to . $loc)")
      }
    }

    # Ensure minimal and sufficient quoting
    locations=(${(q-)locations})

    LBUFFER+="$locations "
  } else {
    LBUFFER+=$partial

    # Change folder instead, if user used alt-enter to abort
    if [[ -r $pathfile ]] {
      local folder=${mapfile[$pathfile]}
      if [[ $folder ]]  cd $folder
      if (( $+functions[.zle::redraw-prompt] ))  zle .zle::redraw-prompt
    }
  }

  # If using fast-syntax-highlighting, retrigger it
  if (( $+functions[_zsh_highlight] ))  _zsh_highlight

}
zle -N       .zle::insert-path-broot
bindkey '^_' .zle::insert-path-broot  # ctrl+/

# -- Pinned view in another tmux pane --
# Key: alt+b, or: esc, b
# Depends: autoload -Uz add-zsh-hook
broot-pin () {
  emulate -L zsh
  local name=$RANDOM

  eval '
    update_pinned_broot_$name () {
      if ! { broot --send '$name' -c ":focus $PWD" 2>/dev/null } {
        add-zsh-hook -d precmd $0
        unfunction jb
      }
    }

    jb () {
      emulate -L zsh
      cd "$(broot --send '$name' --get-root)"
    }
  '

  local orientation_flag=-h size=48
  if (( COLUMNS < 96 )) {
    orientation_flag=-v
    size=24
  }

  add-zsh-hook precmd update_pinned_broot_$name
  tmux splitw -d $orientation_flag -l $size broot --listen $name
}
zle -N broot-pin
bindkey '\eb' broot-pin  # alt+b, or: esc, b

}
