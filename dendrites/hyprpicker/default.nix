{...}: {
  flake.homeModules.hyprpicker = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.modules.hyprpicker;
  in
    with lib; {
      options.modules.hyprpicker = {
        enable = mkEnableOption "hyprpicker";
      };

      config = mkIf cfg.enable {
        home.packages = with pkgs; [
          hyprpicker
        ];
      };
    };
}
