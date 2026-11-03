alias sc="systemctl"
alias scu="systemctl --user"

sc-enabled () {  # [<systemctl-arg>...]
  emulate -L zsh

  local filenames lines enabled_lines 
  lines=(${(f)"$(systemctl $@ list-unit-files)"})
  enabled_lines=(${(M)lines:#* enabled *})
  filenames=(${enabled_lines%% *})

  local -A name_type_pairs=()
  local fname
  for fname ( $filenames )  name_type_pairs+=(${(s:.:)fname})

  local services=() timers=() targets=() sockets=() unit unit_type
  for unit unit_type ( ${(kv)name_type_pairs} ) {
    case $unit_type {
      service)  services+=($unit) ;;
        timer)    timers+=($unit) ;;
       target)   targets+=($unit) ;;
       socket)   sockets+=($unit) ;;
    } 
  }

  local svc
  print 'Services:'
  for svc ( $services )  print -rl -- "  - $svc"
  print 'Timers:'
  for svc ( $timers )    print -rl -- "  - $svc"
  print 'Targets:'
  for svc ( $targets )   print -rl -- "  - $svc"
  print 'Sockets:'
  for svc ( $sockets )   print -rl -- "  - $svc"
}

alias scu-enabled="sc-enabled --user"
