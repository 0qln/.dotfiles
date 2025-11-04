{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.dynIp-updater.afraid;
in {
  options.modules.dynIp-updater.afraid = {
    enable = mkEnableOption "afraid dynamic ip updater";

    domains = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "The list of domains to update.";
    };

    credentialsFile = mkOption {
      type = types.path;
      description = "The path to the encrypted credentials file.";
    };

    serviceSystemUser = mkOption {
      type = types.str;
      default = serviceName;
      description = "The user that this service will operate under.";
    };

    serviceSystemGroup = mkOption {
      type = types.str;
      default = serviceName;
      description = "The group of the serviceUser.";
    };
  };

  config = mkIf cfg.enable (let
    serviceName = "dynIp-updater-afraid";
    secretsName = "${serviceName}/credentials.env";
  in {
    environment.systemPackages = with pkgs; [
      curl
      bash
    ];

    users.groups.${cfg.serviceSystemGroup} = {};
    users.users.${cfg.serviceSystemUser} = {
      group = cfg.serviceSystemGroup;
      isSystemUser = true;
    };

    sops.secrets.${secretsName} = {
      sopsFile = cfg.credentialsFile;
      owner = cfg.serviceSystemUser;
      group = cfg.serviceSystemGroup;
      mode = "0400";
      format = "dotenv";
    };

    systemd.services.${serviceName} = {
      after = ["network.target"];
      wants = ["network-online.target"];
      description = "Send dynamic ip address changes to afraid.org.";
      serviceConfig = {
        User = cfg.serviceSystemUser;
        Group = cfg.serviceSystemGroup;
        ExecStart = pkgs.writeShellScript serviceName ''
          #!${pkgs.bash}/bin/bash
          set -euo pipefail
          source "${config.sops.secrets.${secretsName}.path}"
          IP=$(${pkgs.curl}/bin/curl ipinfo.io/ip)
          echo "ip: $IP"
          ${
            lib.strings.concatMapStrings
            (domain: ''
              ${pkgs.curl}/bin/curl -sSf "http://$USERNAME:$PASSWORD@freedns.afraid.org/nic/update?hostname=${domain}&myip=$IP"
            '')
            cfg.domains
          }
        '';
        Restart = "on-failure";
        RestartSec = "30s";
        LockPersonality = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
      };
    };

    systemd.timers.${serviceName} = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "10min";
        OnUnitActiveSec = "10min";
      };
    };
  });
}
