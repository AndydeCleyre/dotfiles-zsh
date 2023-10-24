export PAGER=less
export LESS=JRWXij.3

export BAT_THEME=Coldark-Dark
export BAT_STYLE=plain
export BAT_PAGER=

# -- man with style --
man () {  # <man-arg>...
  # standout -> standout
  # no-standout -> no-standout
  # underline -> green underline
  # no-underline -> no-color no-underline
  # bold -> bold
  # blink -> bold red
  # no-bold no-blink no-underline -> no-bold no-color no-underline

  LESS_TERMCAP_so=${(%):-%S} \
  LESS_TERMCAP_se=${(%):-%s} \
  LESS_TERMCAP_us=${(%):-%F{green}%U} \
  LESS_TERMCAP_ue=${(%):-%f%u} \
  LESS_TERMCAP_md=${(%):-%B} \
  LESS_TERMCAP_mb=${(%):-%B%F{red}} \
  LESS_TERMCAP_me=${(%):-%b%f%u} \
  =man $@
}

# -- Page with less --
# Accept <doc>:<line-num> as last arg
l () {  # [<less-arg>...] [<doc>[:<line-num>] (or read stdin)]
  emulate -L zsh -o extendedglob

  local doc linenum
  doc=${@[-1]%:<->##}
  if [[ $doc != ${@[-1]} ]]  linenum=${@[-1]#${doc}:}

  LESS=${LESS:-JRWXij.3}  less ${linenum:++${linenum}} ${linenum:+-N} ${@[1,-2]} ${doc}
}

# -- Highlight with highlight --
hi () {  # [-s <syntax>] [<highlight-arg>...]
  emulate -L zsh

  argv=(${argv:/-s/-S})

  if [[ -v NO_COLOR ]] {
    local syntax_idx=${@[(I)-S]}
    if (( syntax_idx ))  argv=($@[1,$syntax_idx-1] $@[$syntax_idx+2,-1])
    if [[ $1 ]] {
      for 1 { <$1 >&1 }
    } else {
      >&1
    }
    return
  }

  local themes=(
    aiseered
    blacknblue
    bluegreen
    ekvoli
    navy
  )

  highlight -O truecolor -s ${themes[RANDOM % $#themes + 1]} -t 4 --force --stdout $@
}

# -- Highlight with whatever --
# dispatches to rich-cli, highlight, bat, etc. if it can
h () {  # [-s <syntax>] [<doc>... (or read stdin)]
  emulate -L zsh -o extendedglob
  rehash

  # get syntax if first arg is md/rst file,
  # or pop if passed with -[Ss]
  local syntax syntax_idx=${@[(I)-[Ss]]}
  if (( syntax_idx )) {
    syntax=${@[$syntax_idx+1]}
    argv=($@[1,$syntax_idx-1] $@[$syntax_idx+2,-1])
  } else {
    case $1 {
      *(#i).rst)  syntax=rst  ;;
      *(#i).md)   syntax=md   ;;
    }
  }

  if [[ -v NO_COLOR ]] {
    if [[ $1 ]] {
      for 1 { <$1 >&1 }
    } else {
      >&1
    }
    return
  }

  # use special highlighters if present, for md/rst/diff
  local hi
  case $syntax {
    md)
      for hi ( mdcat glow ) {
        if (( $+commands[$hi] )) {

          case $hi {
            # ensure it passes style though pipes to a pager:
            glow)   argv=(-s dark $@)  ;;

            # do not fetch remote images:
            mdcat)  argv=(--local $@)  ;;
          }

          $hi $@
          return

        }
      }
    ;;
    rst)
      if (( $+commands[pandoc] )) {
        if (( $+commands[mdcat] )) || (( $+commands[glow] )) {

          for 1 { $0 -s md =(pandoc $1 --to commonmark) }
          return

        }
      }
    ;;
    diff)
      for hi ( riff delta diff-so-fancy colordiff ) {
        if (( $+commands[$hi] )) {

          $hi $@
          return

        }
      }
    ;;
  }

  if (( $+commands[rich] )) {

    local r_args=(--force-terminal --guides -W $(( COLUMNS-4 )))
    if [[ $syntax ]] {
      if [[ $syntax == yml ]]  syntax=yaml
      r_args+=(--lexer $syntax)
    }

    if [[ ! -t 0  ]] {
      rich $r_args -
    } else {
      for 1 { rich $r_args $1 }
    }

  } elif (( $+commands[highlight] )) {

    local themes=(aiseered blacknblue bluegreen ekvoli navy)

    local h_args=(-O truecolor -s ${themes[RANDOM % $#themes + 1]} -t 4 --force --stdout $@)
    if [[ $syntax ]]  h_args+=(-S $syntax)

    # Empty input can yield unwanted newlines as output from highlight.
    # https://gitlab.com/saalen/highlight/-/issues/147
    # This can be avoided in highlight >= 3.56 with: --no-trailing-nl=empty-file
    # As a workaround for more version support,
    # we check stdin for non-emptiness before passing it along to highlight.

    if [[ ! -t 0 ]] {
      local content=$(<&0)
      if [[ $content ]]  highlight $h_args <<<$content
    } else {
      highlight $h_args
    }

  } elif (( $+commands[bat] )) {

    if [[ $syntax ]]  argv+=(-l $syntax)
    bat -p --paging never --color always $@
  } elif (( $+commands[batcat] )) {
    if [[ $syntax ]]  argv+=(-l $syntax)
    batcat -p --paging never --color always $@

  } else {
    cat $@
  }
}
alias hs="h -s"  # <syntax> [<file> (or read stdin)]

# -- Highlight and page --
# Depends: h
lh () {  # [<doc>[:<line-num>]] [-s <syntax>] [<h-arg>...]
  emulate -L zsh -o extendedglob

  # syntax can be specified before doc as well
  local doc_idx=1 syntax_idx=${@[(I)-[Ss]]}
  if [[ $syntax_idx == 1 ]]  doc_idx=3

  # strip the optional :<line-num> from <doc>
  local doc=${@[$doc_idx]%:<->##}

  # extract <line_num> to pass to less
  local linenum
  if [[ $doc != ${@[$doc_idx]} ]]  linenum=${@[$doc_idx]#${doc}:}

  h ${doc} ${@[0,$doc_idx-1]} ${@[$doc_idx+1,-1]} | LESS=${LESS:-JRWXij.3}  less ${linenum:++${linenum}} ${linenum:+-N}
}

# -- Highlight files, showing filenames --
# Depends: h
# Usage: sho file.py second.toml -s ini third.cfg
sho () {  # [-s <syntax>] <code-file> [[-s <syntax>] <code-file>]...
  emulate -L zsh

  local syntax h_args
  while [[ $@ ]] {
    if [[ $1 == -s ]] {
      shift
      syntax=$1
      shift
    } else {
      print -rlPu2 -- "%F{blue}==>%f%F{green} $1 %f%F{blue}<==%f"
      h_args=()
      if [[ $syntax ]]  h_args+=(-s $syntax)
      syntax=
      h $h_args $1
      shift
    }
  }
}

# -- Completion Help Messages --
# Depends: .zshrc_help_complete
if (( $+functions[.zshrc_help_complete] ))  .zshrc_help_complete l hi h lh sho
