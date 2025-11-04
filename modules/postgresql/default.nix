{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.postgresql;
in {
  options.modules.postgresql = {
    enable = mkEnableOption "postgresql";
    serviceDataDir = mkOption {
      type = types.str;
      default = "/mnt/store-1/services/postgresql";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      dataDir = cfg.serviceDataDir;
    };

    # ensure files exist with respective permissions
    # docs: https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html#
    # helpful for debugging tmpfiles.d: https://discourse.nixos.org/t/systemd-tmpfiles-does-not-create-files-and-directories/48422/2?u=0qln
    systemd.tmpfiles.rules = [
      "d ${dirOf cfg.serviceDataDir} 0755 root root - -"
      "d ${cfg.serviceDataDir} 0700 postgres postgres - -"
    ];
  };
}
