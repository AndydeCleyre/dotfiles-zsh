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

# -- Upgrade plugins --
# Pull any git repos in ZSH_PLUGINS_DIR
# Optional: ZSH_PLUGINS_DIR
# Sets:     ZSH_PLUGINS_DIR
.zshrc_upgrade-plugins () {
  emulate -L zsh

  ZSH_PLUGINS_DIR=${ZSH_PLUGINS_DIR:-${${(%):-%x}:P:h}/plugins}  # adjacent plugins/ folder unless already set

  local folder
  for folder ( ${ZSH_PLUGINS_DIR}/*(/) ) {
    git -C $folder remote get-url "$(git -C $folder remote)"
    git -C $folder pull
  }
}

# -- Regenerate outdated files --
# Do nothing if check-cmd isn't in PATH
.zshrc_fortnightly () {  # <check-cmd> <dest> <gen-cmd>
  emulate -L zsh -o extendedglob

  local check_cmd=$1; shift
  local dest=$1     ; shift
  local gen_cmd=($@)

  if ! (( $+commands[$check_cmd] ))  return

  mkdir -p ${dest:a:h}
  if [[ ! ${dest}(#qmw-2N) ]] {
    $gen_cmd >$dest
  }
}
