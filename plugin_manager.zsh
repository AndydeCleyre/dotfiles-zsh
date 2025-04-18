# -- Load plugins --
# Either check ZSH_PLUGINS_DIR for each named plugin folder:
#   .zshrc_load-plugin <plugin-name>...
# Or check a few file or folder paths for a single plugin:
#   .zshrc_load-plugin --try <probable-plugin-path> <alt-plugin-path>...
# Optional: ZSH_PLUGINS_DIR
# Sets:     ZSH_PLUGINS_DIR
.zshrc_load-plugin () {
  emulate zsh

  ZSH_PLUGINS_DIR=${ZSH_PLUGINS_DIR:-${${(%):-%x}:P:h}/plugins}  # adjacent plugins/ folder unless already set

  local plugin_path

  if [[ $1 == --try ]] {
    shift

    for 1 {
      if [[ -d $1 ]] {
        plugin_path=(${1}/*.plugin.zsh(Y1N))
        if [[ ! -r $plugin_path ]] {
          if [[ -r ${1}/init.zsh ]]  plugin_path=${1}/init.zsh
        }
      } else { plugin_path=$1 }

      if [[ -r $plugin_path ]] { . $plugin_path; break }
    }

  } else {

    for 1 {
      plugin_path=(${ZSH_PLUGINS_DIR}/${1}/*.plugin.zsh(Y1N))
      if [[ -r $plugin_path ]] {
        . $plugin_path
      } elif [[ -r ${ZSH_PLUGINS_DIR}/${1}/init.zsh ]] {
        . ${ZSH_PLUGINS_DIR}/${1}/init.zsh
      }
    }

  }

}

# -- Regenerate outdated files --
# Do nothing and return 1 if check-cmd isn't in PATH,
# or if <funcname> is already defined outside home
.zshrc_fortnightly () {  # [--unless <funcname>] <check-cmd> <dest> <gen-cmd>...
  emulate -L zsh -o extendedglob

  if [[ $1 == --unless ]] {
    shift
    if { .zshrc_defined_beyond_home $1 }  return 1
    shift
  }

  local check_cmd=$1; shift
  local dest=$1     ; shift
  local gen_cmd=($@)

  if ! (( $+commands[$check_cmd] ))  return 1

  mkdir -p ${dest:a:h}
  if [[ ! ${dest}(#qmw-2N) ]]  $gen_cmd >$dest
}

# -- Is (potentially autoloading) function defined outside user's home? --
# Succeed if defined outside home, return 1 otherwise
.zshrc_defined_beyond_home () {  # <funcname>
  emulate -L zsh

  autoload -r $1
  local funcpath=$functions_source[$1]

  [[ $funcpath ]] && [[ ${funcpath:#$HOME/*} ]]
}
