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
    records = mkOption {
      type = types.attrs;
      default = {};
      example = {
        root = ./root.env;
        wildcard = ./wildcard.env;
      };
    };
  };
  config = mkIf cfg.enable (let
    serviceName = "dynIp-updater.cloudflare";
    systemUser = "dynIp-updater-cloudflare";
    unitName = name:
      if name == "*"
      then serviceName
      else "${serviceName}-${name}";
    secretName = name: "${serviceName}/${unitName name}/config";
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

    sops.secrets = let
      mkSecret = name: config:
        nameValuePair (secretName name) {
          sopsFile = config;
          owner = systemUser;
          group = systemUser;
          mode = "0400";
          format = "dotenv";
        };
    in
      attrsets.mapAttrs' mkSecret cfg.records;

    systemd.services = let
      mkUpdater = name: _config:
        nameValuePair (unitName name) {
          after = ["network.target"];
          wants = ["network-online.target"];
          description = "Send dynamic ip address changes to cloudflare.";
          serviceConfig = {
            User = systemUser;
            Group = systemUser;
            ExecStart = pkgs.writeShellScript serviceName ''
              set -euo pipefail

              source "${config.sops.secrets.${secretName name}.path}"

              IP=$(${getExe pkgs.curl} ipinfo.io/ip)
              echo "ip: $IP"

              ${getExe pkgs.curl} https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID \
                -X PUT \
                -H 'Content-Type: application/json' \
                -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
                -d "${strings.escape ["\""] (builtins.toJSON {
                name = "$DNS_RECORD_NAME";
                type = "$DNS_RECORD_TYPE";
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
        };
    in
      attrsets.mapAttrs' mkUpdater cfg.records;

    systemd.timers = let
      mkTimer = name: _config: (nameValuePair (unitName name) {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "10min";
          OnUnitActiveSec = "10min";
        };
      });
    in
      attrsets.mapAttrs' mkTimer cfg.records;
  });
}
