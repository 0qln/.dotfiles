{ tokenFile, domains }:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  serviceName = "dynIp-updater-duckdns";
  systemUser = "dynIp-updater-duckdns";
  domainsStr = lib.concatStringsSep "," domains;
in
{
  config = {
    environment.systemPackages = with pkgs; [
      curl
      bash
    ];

    users.groups.${systemUser} = { };
    users.users.${systemUser} = {
      group = systemUser;
      isSystemUser = true;
    };

    sops.secrets."${serviceName}/token" = {
      sopsFile = tokenFile;
      owner = systemUser;
      group = systemUser;
      mode = "0400";
      format = "binary";
    };

    systemd.services.${serviceName} = {
      after = [ "network.target" ];
      wants = [ "network-online.target" ];
      description = "Send dynamic ip address changes to duckdns.";
      serviceConfig = {
        User = systemUser;
        Group = systemUser;
        ExecStart = pkgs.writeShellScript serviceName ''
          #!${pkgs.bash}/bin/bash
          set -euo pipefail
          TOKEN=$(cat "${config.sops.secrets."${serviceName}/token".path}")
          ${pkgs.curl}/bin/curl -sSf "https://www.duckdns.org/update?domains=${domainsStr}&token=$TOKEN&verbose=true"
        '';
        Restart = "on-failure";
        RestartSec = "30s";
        LockPersonality = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
      };
    };

    systemd.timers.${serviceName} = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = "2min";
      };
    };

  };
}
