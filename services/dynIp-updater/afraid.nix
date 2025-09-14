{
  credentialsFile,
  domains,
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  serviceName = "dynIp-updater-afraid";
  secretsName = "${serviceName}/credentials.env";
  systemUser = "dynIp-updater-afraid";
in {
  config = {
    environment.systemPackages = with pkgs; [
      curl
      bash
    ];

    users.groups.${systemUser} = {};
    users.users.${systemUser} = {
      group = systemUser;
      isSystemUser = true;
    };

    sops.secrets.${secretsName} = {
      sopsFile = credentialsFile;
      owner = systemUser;
      group = systemUser;
      mode = "0400";
      format = "dotenv";
    };

    systemd.services.${serviceName} = {
      after = ["network.target"];
      wants = ["network-online.target"];
      description = "Send dynamic ip address changes to afraid.org.";
      serviceConfig = {
        User = systemUser;
        Group = systemUser;
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
            domains
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
  };
}
