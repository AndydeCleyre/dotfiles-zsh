export PAGER=less
if (( $+commands[moor] ))  export PAGER=moor  # do I want this?

export LESS=RWXij.3
export MOOR='-no-linenumbers -style onedark -no-clear-on-exit -wrap'

export BAT_THEME=Coldark-Dark
export BAT_STYLE=plain
export BAT_PAGER=

# -- man with style --
man () {  # <man-arg>...
  # standout -> standout
  # no-standout -> no-standout
  # italic -> italic green
  # no-italic -> no-color no-italic
  # bold -> bold white
  # blink -> bold red
  # no-bold no-blink no-underline -> no-bold no-color no-underline

  GROFF_NO_SGR=1 \
  LESS_TERMCAP_so=${(%):-%S} \
  LESS_TERMCAP_se=${(%):-%s} \
  LESS_TERMCAP_us=${(%):-%F{green}}$'\e[3m' \
  LESS_TERMCAP_ue=${(%):-%f}$'\e[0m' \
  LESS_TERMCAP_md=${(%):-%B%F{white}} \
  LESS_TERMCAP_mb=${(%):-%B%F{red}} \
  LESS_TERMCAP_me=${(%):-%b%f%u} \
  =man $@
}

# -- Page with less or moor --
# Accept <doc>:<line-num> as last arg
# Depends: less, or moor (and mor func)
l () {  # [<less-arg>...] [<doc>[:<line-num>] (or read stdin)]
  emulate -L zsh -o extendedglob

  if (( $+commands[moor] )) {
    mor $@
    return
  }

  local doc linenum
  doc=${@[-1]%:<->##}
  if [[ $doc != ${@[-1]} ]]  linenum=${@[-1]#${doc}:}

  LESS=${LESS:-RWXij.3}  less ${linenum:++${linenum}} ${linenum:+-N} ${@[1,-2]} ${doc}
}

# -- Highlight with highlight --
# Depends: highlight ( https://gitlab.com/saalen/highlight )
hi () {  # [-s <syntax>] [<filepath>...]
  emulate -L zsh

  local themes=(
    # aiseered
    base16/gruvbox-dark-pale
    # base16/snazzy
    # blacknblue
    bluegreen
    # ekvoli
    navy
  )

  argv=(
    --out-format=truecolor
    --style=${themes[RANDOM % $#themes + 1]}
    --replace-tabs=2
    --force
    --stdout
    ${@:/-s/-S}
  )

  if [[ -t 0 ]] {
    highlight $@
  } else {
    local content=$(<&0)
    if [[ $content ]]  highlight $@ <<<$content
  }
  # Empty input can yield unwanted newlines as output from highlight.
  # https://gitlab.com/saalen/highlight/-/issues/147
  # This can be avoided in highlight >= 3.56 with: --no-trailing-nl=empty-file
  # As a workaround for more version support,
  # we check stdin for non-emptiness before passing it along to highlight.
}

# -- Highlight with rich-cli --
# Depends: rich-cli (PyPI)
# Optional: zpy/pipx/uv and pypi-install (misc_python.zsh)
ric () {  # [-s <syntax>] [<filepath>...]
  emulate -L zsh -o errreturn
  rehash

  if (( ! $+commands[rich] )) && (( $+functions[pypi-install] ))  pypi-install rich-cli

  local r_args=(
    --force-terminal
    --guides
    --max-width $(( COLUMNS-4 ))
    --theme native
  )

  local syntax syntax_idx=${@[(I)-s]}
  if (( syntax_idx )) {
    syntax=${@[syntax_idx+1]}
    argv=($@[1,syntax_idx-1] $@[syntax_idx+2,-1])

    if [[ $syntax == yml ]]  syntax=yaml
    r_args+=(--lexer $syntax)
  }

  if [[ -t 0  ]] {
    for 1 { rich $r_args $1 }
  } else {
    rich $r_args -
  }
}

# -- Highlight with bat --
# Depends: bat
# Optional: mise
bt () {  # [-s <syntax>] [<filepath>...]
  emulate -L zsh
  rehash

  local syntax syntax_idx=${@[(I)-s]}
  if (( syntax_idx )) {
    syntax=${@[syntax_idx+1]}
    argv=($@[1,syntax_idx-1] $@[syntax_idx+2,-1])
  }

  # TODO: above and below to helper function. foo ini=conf,hook yaml=nt,nestedtext,hjson
  # ( argv substitution... -- argv' syntax )
  if ! [[ $syntax ]]  syntax=${@[-1]:e}
  if ! [[ $syntax ]]  syntax=${@[-1]:r}
  case $syntax {
    nt|nestedtext)  syntax=yaml ;;
  }

  if [[ $syntax ]]  argv+=(-l $syntax)
  argv+=(--style=plain --pager=never --color=always)

  if (( $+commands[bat] )) {
    bat $@
  } elif (( $+commands[batcat] )) {
    batcat $@
  } elif (( $+functions[mise] )) {
    mise x bat -- bat $@
  } else {
    return 1
  }
}

# -- Highlight stdin or a single file with an installed highlighter, without structural transformation --
# Depends: hi, gt, ric, bt
# Optional: highlight, gat, rich-cli, bat
.zshrc::printing::simple-highlight () {  # [-s <syntax>] [<filepath>]
  emulate -L zsh
  rehash

  if (( $+commands[highlight] )) {
    hi $@
  } elif (( $+commands[gat] )) {
    gt $@
  } elif (( $+commands[rich] )) {
    ric $@
  } elif (( $+commands[bat] )) || (( $+commands[batcat] )) {
    bt $@
  } else {
    local syntax_idx=${@[(I)-s]}
    if (( syntax_idx ))  argv=($@[1,syntax_idx-1] $@[syntax_idx+2,-1])

    cat $@
  }
}

.zshrc::printing::json () {  # [<filepath>]
  emulate -L zsh

  local content
  if ! [[ -t 0 ]] {
    content=$(<&0)
    exec < <(<<<$content)
  }

  local hi hi_args=()
  for hi ( 2nt json2nt jq jello ) {
    if (( $+commands[$hi] )) {

      hi_args=()
      case $hi {
        jq)
          hi_args=(--color-output)
          if [[ $1 ]]  hi_args+=(.)
        ;; 2nt)
          hi_args=(json)
        ;; jello)
          hi_args=(-C)
          if [[ $1 ]]  hi_args+=(-f)
      }
      hi_args+=($1)

      if { FORCE_COLOR=1 $hi $hi_args }  return
      if ! [[ $1 ]]  exec < <(<<<$content)
    }
  }
  return 1
}

.zshrc::printing::diff () {  # [<filepath>]
  emulate -L zsh

  local content
  if ! [[ -t 0 ]] {
    content=$(<&0)
    exec < <(<<<$content)
  }

  local hi hi_args=()
  for hi ( riff delta diff-so-fancy colordiff ) {
    if (( $+commands[$hi] )) {
    # TODO: this does not work for all file args yet! whoops!
    # no file args: all good
    # one file arg: need to redirect its content as stdin? not for riff anymore...
    # two file args: good except for diff-so-fancy and diffr

      hi_args=()
      case $hi {
        riff)
          hi_args+=(--no-pager --color on)
          if [[ $1 ]]  hi_args+=(--file)
        ;; delta)
          hi_args=(--paging never)
        ;; colordiff)
          hi_args=(--color=always)
        ;;
      }
      hi_args+=($1)

      if { $hi $hi_args }  return
      if ! [[ $1 ]]  exec < <(<<<$content)
    }
  }
  return 1
}

.zshrc::printing::2nt () {  # <syntax> [<filepath>]
  emulate -L zsh

  local content
  if ! [[ -t 0 ]] {
    content=$(<&0)
    exec < <(<<<$content)
  }

  if [[ $1 == yml ]]  argv=(yaml ${@[2,-1]})

  if (( $+commands[2nt] )) {
    if { FORCE_COLOR=1 2nt $@ }  return
    if ! [[ $2 ]]  exec < <(<<<$content)
  }
  return 1
}

.zshrc::printing::markdown () {  # [<filepath>]
  emulate -L zsh

  local content
  if ! [[ -t 0 ]] {
    content=$(<&0)
    exec < <(<<<$content)
  }

  local hi hi_args=()
  # glow is not behaving well when piped out to a pager
  for hi ( gum mdcat leaf lowdown ) {
  # gat, glow omitted for now
    if (( $+commands[$hi] )) {

      hi_args=()
      case $hi {
        gat)      hi_args=(--force-color --render-markdown) ;;
        glow)     hi_args=(--style dark)                    ;;  # ensure it passes style though pipes to a pager
        # TODO: https://github.com/charmbracelet/glow/issues/654
        gum)      hi_args=(format)                          ;;
        leaf)     hi_args=(--inline ansi --width $COLUMNS)  ;;
        lowdown)  hi_args=(-t term)                         ;;
        mdcat)    hi_args=(--local)                         ;;  # do not fetch remote images
      }

      if [[ $hi == gum ]] && [[ $1 ]] {
        if { CLICOLOR_FORCE=1 $hi $hi_args <$1 }  return
      } else {
        hi_args+=($1)
        if { CLICOLOR_FORCE=1 $hi $hi_args }  return
      }
      if ! [[ $1 ]]  exec < <(<<<$content)
    }
  }
  return 1
}

.zshrc::printing::rst () {  # [<filepath>]
  emulate -L zsh

  local content
  if ! [[ -t 0 ]] {
    content=$(<&0)
    exec < <(<<<$content)
  }

  if (( $+commands[pandoc] )) {
    if (( $+commands[gum] )) || (( $+commands[mdcat] )) || (( $+commands[glow] )) {
      local md_content=$(pandoc $1 --to commonmark)
      if (( ! $? )) && { .zshrc::printing::markdown <<<$md_content }  return
      if ! [[ $1 ]]  exec < <(<<<$content)
    }
  }

  return 1
}

.zshrc::printing::djot () {  # [<filepath>]
  emulate -L zsh

  local content
  if ! [[ -t 0 ]] {
    content=$(<&0)
    exec < <(<<<$content)
  }

  local hi hi_args=()
  for hi ( tjot pandoc ) {
    if (( $+commands[$hi] )) {

      hi_args=()
      case $hi {
        tjot)    hi_args=(-w $COLUMNS -n)     ;;
        pandoc)  hi_args=(-f djot -t ansi) ;;
      }
      hi_args+=($1)

      if { $hi $hi_args }  return
      if ! [[ $1 ]]  exec < <(<<<$content)
    }
  }
  return 1
}

.zshrc::printing::xmq () {  # [<filepath>]
  emulate -L zsh

  local content
  if ! [[ -t 0 ]] {
    content=$(<&0)
    exec < <(<<<$content)
  }

  local hi_args=()
  if (( $+commands[xmq] )) {

    hi_args=($1 render-terminal --bg=dark)

    if { xmq $hi_args }  return
    if ! [[ $1 ]]  exec < <(<<<$content)
  }
  return 1
}

.zshrc::printing::log () {  # [<filepath>]
  emulate -L zsh

  local content
  if ! [[ -t 0 ]] {
    content=$(<&0)
    exec < <(<<<$content)
  }

  local hi hi_args=()
  for hi ( tspin ) {
    if (( $+commands[$hi] )) {

      hi_args=()
      case $hi {
        tspin)   hi_args=(--print $1)       ;;
        # splash)  if [[ $1 ]]  exec < <(<$1) ;;
      }

      if { $hi $hi_args }  return
      if ! [[ $1 ]]  exec < <(<<<$content)
    }
  }
  return 1
}

# -- Highlight with whatever --
h () {  # [-s <syntax>] [<filepath>... (or read stdin)]
# dispatches to rich-cli, highlight, bat, etc. if it can
# Depends:
#   - hi, gt, ric
# TODO: update depends and optional
# Optional:
#   - bat/highlight/rich-cli/gat
#   - colordiff/delta/diff-so-fancy/riff/diffr
#   - glow/mdcat/gum/lowdown, jq/jello, nt2 (PyPI), pandoc, tspin, splash, xmq
  emulate -L zsh -o extendedglob
  rehash

  # Pop and set syntax if passed with -s
  local syntax syntax_idx=${@[(I)-s]}
  if (( syntax_idx )) {
    syntax=${@[syntax_idx+1]}
    argv=($@[1,syntax_idx-1] $@[syntax_idx+2,-1])
  }

  # Simply print if NO_COLOR
  if [[ -v NO_COLOR ]] {
    if [[ $1 ]] {
      for 1 { <$1 >&1 }
    } else {
      >&1
    }
    return
  }

  # Call self with one file at a time
  if (( $#@ > 1 )) {
    for 1 { $0 ${syntax:+-s} $syntax $1 }
    return
  }

  # Still here? Must be a single file or stdin

  # Set syntax from file extension if not passed
  if [[ $1 ]] && [[ ! $syntax ]] {
    syntax=${1:e:l}

    # Replace some known alternate extensions:
    case $syntax {
      factor-*)  syntax=factor ;;
    }
    if ! [[ $syntax ]] {  # no extension
      case ${1:t} {
        kglobalshortcutsrc)  syntax=ini ;;
      }
    }

  }

  # Try dispatching to a specialized highlighter
  case $syntax {
    json)
      if { .zshrc::printing::json        $1 }  return ;;  # TODO: fall through to 2nt
    md)
      if { .zshrc::printing::markdown    $1 }  return ;;
    dj(ot|))
      if { .zshrc::printing::djot        $1 }  return ;;
    # y(a|)ml|toml|huml|kson|hjson)
    #   if { .zshrc::printing::2nt $syntax $1 }  return ;;
    log)
      if { .zshrc::printing::log         $1 }  return ;;
    (ht|x)ml)
      if { .zshrc::printing::xmq         $1 }  return ;;
    rst)
      if { .zshrc::printing::rst         $1 }  return ;;
    diff|patch)
      if { .zshrc::printing::diff        $1 }  return ;;
  }

  # Generic/fallback highlighter
  .zshrc::printing::simple-highlight ${syntax:+-s} $syntax $1
}

alias hs="h -s"  # <syntax> [<filepath>... (or read stdin)]

# -- Highlight and page --
# Depends: h, and less or moor
lh () {  # [<doc>[:<line-num>]] [-s <syntax>] [<h-arg>...]
  emulate -L zsh -o extendedglob

  # syntax can be specified before doc as well
  local doc_idx=1 syntax_idx=${@[(I)-s]}
  if [[ $syntax_idx == 1 ]]  doc_idx=3

  # strip the optional :<line-num> from <doc>
  local doc=${@[doc_idx]%:<->##}

  # extract <line_num> to pass to less
  local linenum
  if [[ $doc != ${@[doc_idx]} ]]  linenum=${@[doc_idx]#${doc}:}

  if (( $+commands[moor] )) {
    if (( linenum == 0 ))  linenum=

    h ${doc} ${@[0,doc_idx-1]} ${@[doc_idx+1,-1]} | MOOR='-no-linenumbers -style onedark -no-clear-on-exit -wrap' moor ${linenum:++${linenum}} ${linenum:+-no-linenumbers=f}
  } else {
    h ${doc} ${@[0,doc_idx-1]} ${@[doc_idx+1,-1]} | LESS=${LESS:-RWXij.3}  less ${linenum:++${linenum}} ${linenum:+-N}
  }
}

# -- Highlight files, showing filenames --
# Depends: h
# Usage: sho file.py second.toml -s ini third.cfg
sho () {  # [-s <syntax>] <code-file> [[-s <syntax>] <code-file>]...
  emulate -L zsh

  local syntax h_args
  while [[ $@ ]] {
    if [[ $1 == -s ]] {
      syntax=$2
      shift 2
    } else {
      print -rlPu2 -- "%F{blue}${(l:$#1+6::~:)}%f"
      print -rlPu2 -- "%F{blue}%B%U  %F{green} $1 %F{blue}  %u%b%f"
      h_args=()
      if [[ $syntax ]]  h_args+=(-s $syntax)
      syntax=
      h $h_args $1
      shift
    }
  }
}

# -- Highlight with gat --
# Depends: gat
# Optional: gh-install (github.zsh) or mise
gt () {  # [-s <syntax>] [<filepath>...]
  emulate -L zsh -o errreturn
  rehash

  # Make explicit when operating on unsupported (but manageable) syntaxes:
  local syntax_idx=${@[(I)-s]}
  if ! (( syntax_idx )) {

    local syntax=${@[-1]:e}
    if ! [[ $syntax ]]  syntax=${@[-1]:r}

    if [[ $syntax =~ '^(nt|nestedtext|hjson|conf|hook)$' ]]  argv+=(-s $syntax)
    syntax_idx=$(($#@-1))
  }

  # Avoid quitting on unknown syntax:
  # https://github.com/koki-develop/gat/issues/285
  # And use good-enough syntax substitutes:
  if (( syntax_idx )) {
    case ${@[syntax_idx+1]} {
      nt|nestedtext|hjson)  argv[syntax_idx+1]=yaml ;;
      conf|hook)            argv[syntax_idx+1]=ini  ;;
      install)              argv[syntax_idx+1]=sh   ;;
    }
  }

  local gat_cmd=( gat )
  if ! (( $+commands[gat] )) {
    if (( $+functions[mise] )) {
      # print installation tip to stderr?:
      # mise use -g github:koki-develop/gat

      gat_cmd=(mise x github:koki-develop/gat -- gat)

    } elif (( $+functions[gh-install] )) {
      gh-install koki-develop gat gat_Linux_x86_64.tar.gz gat
    }
  }

  local themes=(
    base16-snazzy
    doom-one
    gruvbox
    onedark
    vulcan  # comments might be too dark
  )

  $gat_cmd --force-color -t ${themes[RANDOM % $#themes + 1]} ${@:/-s/-l}
}

# -- Highlight and page with moor --
# Depends: moor
# Optional: mise
mor () {  # [-s <syntax>] [<doc>[:<line-num>] (or read stdin)]
  emulate -L zsh -o extendedglob
  rehash

  local doc_idx=1 syntax_idx=${@[(I)-s]}
  if [[ $syntax_idx == 1 ]]  doc_idx=3

  local syntax
  if (( syntax_idx ))  syntax=${@[syntax_idx+1]}

  # strip the optional :<line-num> from <doc>
  local doc=${@[doc_idx]%:<->##}

  local linenum
  if [[ $doc != ${@[doc_idx]} ]]  linenum=${@[doc_idx]#${doc}:}

  if (( linenum == 0 ))  linenum=

  local themes=(
    base16-snazzy
    doom-one
    gruvbox
    onedark
    vulcan  # comments might be too dark
  )

  local args=(
    ${syntax:+-lang} $syntax
    -no-clear-on-exit
    -style ${themes[RANDOM % $#themes + 1]}
    -wrap
  )
  if [[ $linenum ]] {
    args+=(-no-linenumbers=f +${linenum})
  } else {
    args+=(-no-linenumbers)
  }
  args+=($doc)

  if ! (( $+commands[moor] )) {
    if (( $+functions[mise] ))  mise x github:walles/moor -- moor $args
  } else {
    moor $args
  }
}

# TODO: archive previews, with ouch and others?

# -- Make HTML and XML readable with xmq --
# Depends: xmq
# Optional: gh-install (github.zsh) or mise
xmq () {
  emulate -L zsh -o errreturn
  rehash

  local xmq_cmd=( =xmq )
  if ! (( $+commands[xmq] )) {
    if (( $+functions[mise] )) {
      xmq_cmd=( mise x github:libxmq/xmq -- xmq )
    } elif (( $+functions[gh-install] )) {
      gh-install libxmq xmq xmq-gnulinux-release.tar.gz xmq
    }
  }

  $xmq_cmd $@
}

# -- Completion Help Messages --
# Depends: .zshrc_help_complete (help.zsh)
if (( $+functions[.zshrc_help_complete] ))  .zshrc_help_complete gt l lh h hi ric sho mor
