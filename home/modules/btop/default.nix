{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.btop;
in {
  options.modules.btop = {
    enable = mkEnableOption "btop";
  };

  config = mkIf cfg.enable {
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "TTY";
        theme_background = false;
        truecolor = true;
        vim_keys = true;
        force_tty = false;
        rounded_corners = true;
        show_battery = false;
        check_temp = true;
        show_uptime = true;
        cpu_top = true;
      };
    };
  };
}
