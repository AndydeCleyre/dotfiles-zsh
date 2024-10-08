export EDITOR=micro
export MICRO_TRUECOLOR=1

alias e="$EDITOR"

xt () { touch "$@"; chmod ug+x "$@" }
xe () { xt "$@"; $EDITOR "$@" }
xsubl () { xt "$@"; subl "$@" }

mcdiff () {  # [<mcdiff-arg>...]
  emulate -L zsh

  local skins=(
    gotar
    gray-green-purple256
    modarin256-defbg
    modarin256
    modarin256root-defbg
    modarin256root
    sand256
    seasons-autumn16M
    seasons-spring16M
    seasons-summer16M
    seasons-winter16M
    yadt256-defbg
    yadt256
  )

  local skin=${skins[RANDOM % $#skins + 1]}

  print -rl -- "Using skin: $skin:t:r"
  COLORTERM=truecolor =mcdiff -c -S $skin $@
}

# https://github.com/zed-industries/zed/issues/17413
compdef _gnu_generic zed
