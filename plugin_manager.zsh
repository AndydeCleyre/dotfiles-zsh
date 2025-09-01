# -- Load plugins --
# Either check plugins folder for each named plugin folder and load all found:
#   .zshrc::load-plugin <plugin-name>...
# Or check a few file or folder paths for a single plugin and load up to one:
#   .zshrc::load-plugin --try <probable-plugin-path> <alt-plugin-path>...
# Optional: ZSH_PLUGINS_DIR
.zshrc::load-plugin () {
  emulate zsh

  local plugins_dir=${ZSH_PLUGINS_DIR:-${${(%):-%x}:P:h}/plugins}  # adjacent plugins/ folder unless already set

  local plugin_path

  if [[ $1 == --try ]] {
    shift

    for 1 {
      plugin_path=$1
      if [[ -d $1 ]] {
        plugin_path=(${1}/*.plugin.zsh(Y1N))
        if [[ ! -r $plugin_path ]]  plugin_path=${1}/init.zsh
        if [[ ! -r $plugin_path ]]  plugin_path=(${1}/*.zsh-theme(Y1N))
      }
      if [[ -r $plugin_path ]] {
        . $plugin_path
        break
      }
    }

  } else {

    for 1 {
      plugin_path=(${plugins_dir}/${1}/*.plugin.zsh(Y1N))
      if [[ ! -r $plugin_path ]]  plugin_path=${plugins_dir}/${1}/init.zsh
      if [[ ! -r $plugin_path ]]  plugin_path=(${plugins_dir}/${1}/*.zsh-theme(Y1N))
      if [[ -r $plugin_path ]]  . $plugin_path
    }

  }

}

# -- Regenerate outdated files --
# Do nothing and return 1 if check-cmd isn't in PATH,
# or if <funcname> is already defined outside home.
.zshrc::fortnightly () {  # [--unless-system <funcname>] <check-cmd> <dest> <gen-cmd> [<gen-cmd-arg>...]
  emulate -L zsh -o extendedglob

  if [[ $1 == --unless-system ]] {
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

# -- Generate Completions for fpath from Commands --
# Depends: .zshrc::fortnightly
.zshrc::generate-fpath-completions () {  # <generation-cmd>... (e.g. 'mise completion zsh')
  emulate -L zsh

  local words
  for 1 {
    words=(${(z)1})
    .zshrc::fortnightly \
      --unless-system _${words[1]} \
      ${words[1]} \
      ${XDG_DATA_HOME:-~/.local/share}/zsh/site-functions/_${words[1]} \
      $words || true
  }
}

# -- Generate Completions for Python Click Apps --
# Depends: .zshrc::fortnightly
.zshrc::generate-fpath-completions-click () {  # <click-tool>...
  emulate -L zsh

  for 1 {
    .zshrc::fortnightly \
      --unless-system _${1} \
      ${1} \
      ${XDG_DATA_HOME:-~/.local/share}/zsh/site-functions/_${1} \
      eval "_${1:u:gs/-/_}_COMPLETE=zsh_source $1" || true
  }
}

# -- Add Completions from Python Packages to fpath --
.zshrc::add-pytool-fpath-entries () {  # <pytool>...
  emulate -L zsh

  local fpathentry
  for 1 {
    if (( $+commands[$1] )) {
      fpathentry=${${:-=$1}:P:h:h}/share/zsh/site-functions
      if [[ -d $fpathentry ]] && ! (( ${fpath[(I)$fpathentry]} ))  fpath=($fpathentry $fpath)
    }
  }
}

# -- Generate and Load a Plugin --
# Do nothing if generation-cmd isn't in PATH,
# or if <funcname> is already defined outside home
# Depends: .zshrc::fortnightly
# Optional: ZSH_PLUGINS_DIR
.zshrc::generate-and-load-plugin () {  # [--unless-system <funcname>] <gen-cmd> [<gen-cmd-arg>...]
  emulate -L zsh

  local plugins_dir=${ZSH_PLUGINS_DIR:-${${(%):-%x}:P:h}/plugins}  # adjacent plugins/ folder unless already set

  local gen_dir=${plugins_dir}/generated
  mkdir -p $gen_dir

  local args=()
  if [[ $1 == --unless-system ]] {
    args+=($1 $2)
    shift 2
  }
  args+=($@[1] ${gen_dir}/${@[1]}.zsh $@)

  if { .zshrc::fortnightly $args }  . ${gen_dir}/${@[1]}.zsh
}
