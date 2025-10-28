{
  inputs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.wsl;
in {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  options.modules.wsl = {
    enable = mkEnableOption "wsl";
    defaultUser = mkOption {
      type = types.nullOr types.str;
      description = "The default user for the wsl sytem to use.";
      default = null;
    };
  };

  config = mkIf cfg.enable {
    wsl = {
      enable = true;
      defaultUser = mkIf (cfg.defaultUser != null) cfg.defaultUser;
    };
  };
}
