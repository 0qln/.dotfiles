{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.vaultwarden;
  port = 8000;
in {
  options.modules.vaultwarden = {
    enable = mkEnableOption "vault warden server";

    backupDir = mkOption {
      type = types.str;
      default = "/mnt/store-1/backups/vaultwarden";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/mnt/store-1/services/vaultwarden";
    };

    environmentFile = mkOption {
      type = types.path;
    };

    fqdn = {
      dn = mkOption {
        type = types.str;
        description = "The primary fqdn.";
      };
      acmeHost = mkOption {
        type = types.str;
        description = "The host domain that has an ssl certificate.";
      };
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."environmentFile" = {
      sopsFile = cfg.environmentFile;
      mode = "0400";
      format = "dotenv";
      owner = "vaultwarden";
      group = "vaultwarden";
    };

    modules.acme.certs.${cfg.fqdn.acmeHost}.aliases = [cfg.fqdn.dn];

    services.nginx.virtualHosts.${cfg.fqdn.dn} = {
      forceSSL = true;
      useACMEHost = cfg.fqdn.acmeHost;
      locations."/" = {
        proxyPass = "http://localhost:${(toString port)}";
      };
    };

    services.vaultwarden = {
      enable = true;
      environmentFile = config.sops.secrets."environmentFile".path;
      config = {
        DOMAIN = "https://${cfg.fqdn.dn}";
        ROCKET_PORT = port;
        DATA_FOLDER = cfg.dataDir;
        SIGNUPS_ALLOWED = false;
      };
      backupDir = "${cfg.backupDir}";
    };

    systemd.services = let
      patches = dir: {
        serviceConfig = {
          ReadWritePaths = mkForce dir;
          ProtectSystem = mkForce "yes";
          Environment = mkForce ["DATA_FOLDER=${cfg.dataDir}"];
        };
      };
    in {
      "vaultwarden" = patches cfg.dataDir;
      "backup-vaultwarden" = patches cfg.backupDir;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 vaultwarden vaultwarden - -"
      "d ${cfg.backupDir} 0755 vaultwarden vaultwarden - -"
    ];
  };
}
