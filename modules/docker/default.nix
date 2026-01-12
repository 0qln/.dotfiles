{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.docker;
in {
  options.modules.docker = {
    enable = mkEnableOption "docker";
    serviceDataDir = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    rootless.enable = mkEnableOption "see `https://search.nixos.org/options?channel=25.11&show=virtualisation.docker.rootless.enable&type=options&query=virtualisation.docker`";
  };

  imports = [
    inputs.arion.nixosModules.arion
  ];

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      daemon.settings = {
        data-root = mkIf (cfg.serviceDataDir != null) cfg.serviceDataDir;
        userland-proxy = false;
      };
      rootless = mkIf cfg.rootless.enable {
        enable = true;
        setSocketVariable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      arion
    ];
  };
}
