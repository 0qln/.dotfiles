# Self-hosted Relay Server (https://github.com/No-Instructions/relay-server-template).
{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules."obsidian-relay" = {
    config,
    pkgs,
    ...
  }: let
    serviceName = "obsidian-relay";
    cfg = config.modules."obsidian-relay";

    url = "https://${cfg.fqdn.dn}";

    configFile = (pkgs.formats.toml {}).generate "relay.toml" {
      server = {
        inherit url;
        host = "0.0.0.0";
        port = 8080;
      };

      store = {
        type = "filesystem";
        path = "/app/data";
      };

      # relay.md control plane public keys, used to verify access tokens
      auth = cfg.authKeys;
    };
  in {
    options.modules."obsidian-relay" = {
      enable = mkEnableOption "Relay Server";

      image = mkOption {
        type = types.str;
        default = "docker.system3.md/relay-server:latest";
        description = "The Relay Server container image.";
      };

      stateDir = mkOption {
        type = types.str;
        default = "/var/lib/obsidian-relay";
        description = "Directory bind-mounted as the container's /app/data.";
      };

      port = mkOption {
        type = types.port;
        default = 8089;
        description = "Loopback host port the container's HTTP port is published on.";
      };

      authKeys = mkOption {
        type = types.listOf (types.attrsOf types.str);
        default = [
          {
            key_id = "relay_2025_10_22";
            public_key = "/6OgBTHaRdWLogewMdyE+7AxnI0/HP3WGqRs/bYBlFg=";
          }
          {
            key_id = "relay_2025_10_23";
            public_key = "fbm9JLHrwPpST5HAYORTQR/i1VbZ1kdp2ZEy0XpMbf0=";
          }
        ];
        description = ''
          Relay.md control plane public keys. Taken from
          https://github.com/No-Instructions/relay-server-template/blob/main/relay.toml.example
        '';
      };

      fqdn = {
        dn = mkOption {
          type = types.str;
          description = ''
            The primary FQDN. `https://<dn>` is the URL that has to be entered in
            the Obsidian `Relay: Register self-hosted Relay Server` command.
          '';
        };

        acmeHost = mkOption {
          type = types.str;
          description = "The host domain that has an SSL certificate.";
        };
      };
    };

    config = mkIf cfg.enable {
      modules = {
        docker.enable = true;
        acme.certs.${cfg.fqdn.acmeHost}.aliases = [cfg.fqdn.dn];
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.stateDir} 0750 root root - -"
      ];

      virtualisation.oci-containers = {
        backend = "docker";

        containers.${serviceName} = {
          inherit (cfg) image;

          volumes = [
            "${configFile}:/app/relay.toml:ro"
            "${cfg.stateDir}:/app/data"
          ];

          ports = ["127.0.0.1:${toString cfg.port}:8080"];
        };
      };

      services.nginx.virtualHosts.${cfg.fqdn.dn} = {
        useACMEHost = cfg.fqdn.acmeHost;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          # document sync runs over websockets
          proxyWebsockets = true;
          extraConfig =
            # nginx
            ''
              proxy_read_timeout 3600s;
              proxy_send_timeout 3600s;
              client_max_body_size 0;
            '';
        };
      };
    };
  };
}
