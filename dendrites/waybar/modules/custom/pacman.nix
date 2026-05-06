{config, ...}: {
  "format" = "󰅢 {}";
  "interval" = 30;
  "exec" = "checkupdates | wc -l";
  "exec-if" = "exit 0";
  "on-click" = "${config.vars.terminal} sh -c 'yay -Syu; echo Done - Press enter to exit; read'; pkill -SIGRTMIN+8 waybar";
  "signal" = 8;
  "tooltip" = false;
}
