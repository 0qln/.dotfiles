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
      type = types.str;
      default = "/mnt/store-1/services/docker";
    };
  };

  imports = [
    inputs.arion.nixosModules.arion
  ];

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      daemon.settings = {
        data-root = cfg.serviceDataDir;
        userland-proxy = false;
      };
    };

    environment.systemPackages = with pkgs; [
      arion
    ];
  };
}
