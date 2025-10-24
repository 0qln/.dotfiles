{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.azure;
in {
  options.modules.azure = {
    enable = mkEnableOption "azure";
  };

  config = mkIf cfg.enable {
    home.packages = [
      # this package is useless, just use the install script from the repo:
      # https://github.com/microsoft/artifacts-credprovider
      # pkgs.azure-artifacts-credprovider
    ];
  };
}
