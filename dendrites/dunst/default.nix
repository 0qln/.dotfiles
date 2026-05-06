{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.homeModules.dunst = {config, ...}: let
    cfg = config.modules.dunst;
  in {
    options.modules.dunst = {
      enable = mkEnableOption "dunst";
      settings = mkOption {
        type = types.attrs;
      };
    };

    config = mkIf cfg.enable {
      services.dunst = {
        enable = true;
        inherit (cfg) settings;
      };
    };
  };
}
