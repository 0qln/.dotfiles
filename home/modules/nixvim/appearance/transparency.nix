{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.nixvim.transparency;
in {
  options.modules.nixvim.transparency = {
    enable = mkEnableOption "transparency";
  };

  config = mkIf cfg.enable {
    programs.nixvim = {
      plugins = {
        transparent = {
          enable = true;
          settings = {
            auto = true;
            groups = [
            ];
          };
        };
      };
    };
  };
}
