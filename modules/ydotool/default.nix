{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.ydotool;
in {
  options.modules.ydotool = {
    enable = mkEnableOption "ydotool";
  };

  config = mkIf cfg.enable {
    programs.ydotool = {
      enable = true;
      group = "input";
    };
  };
}
