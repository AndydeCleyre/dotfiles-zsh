export PAGER=less
export LESS=JRWXij.3

export BAT_THEME=Coldark-Dark
export BAT_STYLE=plain
export BAT_PAGER=

# -- man with style --
man () {  # <man-arg>...
  # standout -> standout
  # no-standout -> no-standout
  # underline -> underline green
  # no-underline -> no-color no-underline
  # bold -> bold white
  # blink -> bold red
  # no-bold no-blink no-underline -> no-bold no-color no-underline

  LESS_TERMCAP_so=${(%):-%S} \
  LESS_TERMCAP_se=${(%):-%s} \
  LESS_TERMCAP_us=${(%):-%F{green}%U} \
  LESS_TERMCAP_ue=${(%):-%f%u} \
  LESS_TERMCAP_md=${(%):-%B%F{white}} \
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
# Depends: highlight ( https://gitlab.com/saalen/highlight )
hi () {  # [-s <syntax>] [<filepath>...]
  emulate -L zsh

  local themes=(
    aiseered
    blacknblue
    bluegreen
    ekvoli
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
ric () {  # [-s <syntax>] [<filepath>...]
  emulate -L zsh

  local r_args=(
    --force-terminal
    --guides
    --max-width $(( COLUMNS-4 ))
    --theme native
  )

  local syntax syntax_idx=${@[(I)-s]}
  if (( syntax_idx )) {
    syntax=${@[$syntax_idx+1]}
    argv=($@[1,$syntax_idx-1] $@[$syntax_idx+2,-1])
  }

  if [[ $syntax ]] {
    if [[ $syntax == yml ]]  syntax=yaml
    r_args+=(--lexer $syntax)
  }

  if [[ -t 0  ]] {
    for 1 { rich $r_args $1 }
  } else {
    rich $r_args -
  }
}

# -- Highlight with whatever --
# dispatches to rich-cli, highlight, bat, etc. if it can
# Depends:
#   - hi
#   - ric
# Optional:
#   - bat/highlight/rich-cli
#   - colordiff/delta/diff-so-fancy/riff
#   - glow/mdcat
#   - jq/jello
#   - pandoc
#   - tspin
#   - xmq
h () {  # [-s <syntax>] [<filepath>... (or read stdin)]
  emulate -L zsh -o extendedglob
  rehash

  # get syntax if first arg is md/rst/log/html/xml/json file,
  # or pop if passed with -s
  local syntax syntax_idx=${@[(I)-s]}
  if (( syntax_idx )) {
    syntax=${@[$syntax_idx+1]}
    argv=($@[1,$syntax_idx-1] $@[$syntax_idx+2,-1])
  } else {
    case $1 {
      (*(#i).rst)  syntax=rst  ;;
      (*(#i).md)   syntax=md   ;;
      (*(#i).html) syntax=html ;;
      (*(#i).xml)  syntax=xml  ;;
      (*(#i).json) syntax=json ;;
      (*(#i).log)  syntax=log
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

  # use special highlighters if present, for md/rst/diff/log/html/xml/json
  local hi
  case $syntax {

    (md)
      for hi ( mdcat glow ) {
        if (( $+commands[$hi] )) {

          case $hi {
            # ensure it passes style though pipes to a pager:
            (glow)   argv=(--style dark $@)  ;;

            # do not fetch remote images:
            (mdcat)  argv=(--local $@)
          }

          $hi $@
          return

        }
      }

    ;; (rst)
      if (( $+commands[pandoc] )) {
        if (( $+commands[mdcat] )) || (( $+commands[glow] )) {

          for 1 { $0 -s md =(pandoc $1 --to commonmark) }
          return

        }
      }

    ;; (diff)
      for hi ( riff delta diff-so-fancy colordiff ) {
        if (( $+commands[$hi] )) {

          # TODO: this does not work for file args yet! whoops!
          # no args all good
          # one arg, maybe redirect its content as stdin
          # two args, maybe good?

          case $hi {
            (riff)      argv=(--no-pager --color on $@) ;;
            (delta)     argv=(--paging never $@)        ;;
            (colordiff) argv=(--color=always $@)
          }

          $hi $@
          return

        }
      }

    ;; (html|xml)
      if (( $+commands[xmq] )) {
        for 1 { xmq $1 render-terminal --color }
        return
      }

    ;; (json)
      for hi ( jq jello ) {
        if (( $+commands[$hi] )) {

          case $hi {
            (jq)
              if (( $#@ ))  argv=(. $@)
              argv=(--color-output $@)
            ;; (jello)
              if (( $#@ ))  argv=(-f $@)
              argv=(-C $@)
          }

          $hi $@
          return

        }
      }

    ;; (log)
      if (( $+commands[tspin] )) {

        tspin --print $@
        return

      }

  }

  if (( $+commands[highlight] )) {

    if [[ $syntax ]]  argv+=(-s $syntax)
    hi $@

  } elif (( $+commands[rich] )) {

    if [[ $syntax ]]  argv+=(-s $syntax)
    ric $@

  } elif (( $+commands[bat] )) {

    if [[ $syntax ]]  argv+=(-l $syntax)
    bat --style=plain --pager=never --color=always $@

  } elif (( $+commands[batcat] )) {

    if [[ $syntax ]]  argv+=(-l $syntax)
    batcat --style=plain --pager=never --color=always $@

  } else {

    cat $@

  }
}
alias hs="h -s"  # <syntax> [<filepath>... (or read stdin)]

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

# -- Completion Help Messages --
# Depends: .zshrc_help_complete (help.zsh)
if (( $+functions[.zshrc_help_complete] ))  .zshrc_help_complete l lh h hi ric sho
