{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.dynIp-updater.cloudflare;
in {
  options.modules.dynIp-updater.cloudflare = {
    enable = mkEnableOption "cloudflare dynamic ip updater";
    configFile = mkOption {
      type = types.path;
    };
    domains = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };
  config = mkIf cfg.enable (let
    serviceName = "dynIp-updater.cloudflare";
    systemUser = "dynIp-updater-cloudflare";
  in {
    environment.systemPackages = with pkgs; [
      curl
      bash
    ];

    users.groups.${systemUser} = {};
    users.users.${systemUser} = {
      group = systemUser;
      isSystemUser = true;
    };

    sops.secrets."${serviceName}/config" = {
      sopsFile = cfg.configFile;
      owner = systemUser;
      group = systemUser;
      mode = "0400";
      format = "dotenv";
    };

    systemd.services = let
      mkUpdater = dn: (nameValuePair "${serviceName}-${dn}" {
        after = ["network.target"];
        wants = ["network-online.target"];
        description = "Send dynamic ip address changes to cloudflare.";
        serviceConfig = {
          User = systemUser;
          Group = systemUser;
          ExecStart = pkgs.writeShellScript serviceName ''
            set -euo pipefail

            source "${config.sops.secrets."${serviceName}/config".path}"

            IP=$(${getExe pkgs.curl} ipinfo.io/ip)
            echo "ip: $IP"

            ${getExe pkgs.curl} https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID \
              -X PUT \
              -H 'Content-Type: application/json' \
              -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
              -d "${strings.escape ["\""] (builtins.toJSON {
              name = dn;
              type = "A";
              content = "$IP";
              ttl = 300;
            })}"
          '';
          Restart = "on-failure";
          RestartSec = "30s";
          LockPersonality = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
        };
      });
    in
      builtins.listToAttrs (map mkUpdater cfg.domains);

    systemd.timers = let
      mkTimer = dn: (nameValuePair "${serviceName}-${dn}" {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "10min";
          OnUnitActiveSec = "10min";
        };
      });
    in
      builtins.listToAttrs (map mkTimer cfg.domains);
  });
}
