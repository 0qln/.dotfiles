{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.homeModules.mako = {config, ...}: let
    cfg = config.modules.mako;
  in {
    options.modules.mako = {
      enable = mkEnableOption "mako";
    };

    config = mkIf cfg.enable {
      services.mako.enable = true;
    };
  };
}
