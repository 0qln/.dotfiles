{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules."sparky-fitness" = {config, ...}: let
    cfg = config.modules."sparky-fitness";
    serviceName = "sparky-fitness";
  in {
    imports = [
      inputs.sparkyfitness.nixosModules.sparkyfitness
    ];

    options.modules."sparky-fitness" = {
      enable = mkEnableOption "SparkyFitness";

      stateDir = mkOption {
        type = types.path;
        default = "/var/lib/sparkyfitness";
        description = "Directory for persistent SparkyFitness state.";
      };

      secretsFile = mkOption {
        type = types.path;
        description = ''
          SOPS file containing the SparkyFitness dotenv secrets.

          Expected keys include SPARKY_FITNESS_DB_PASSWORD,
          SPARKY_FITNESS_APP_DB_PASSWORD, SPARKY_FITNESS_API_ENCRYPTION_KEY,
          and BETTER_AUTH_SECRET.
        '';
      };

      port = mkOption {
        type = types.port;
        default = 3010;
        description = "Port the SparkyFitness backend listens on.";
      };

      fqdn = {
        dn = mkOption {
          type = types.str;
          description = "The primary FQDN.";
        };

        acmeHost = mkOption {
          type = types.str;
          description = "The host domain that has an SSL certificate.";
        };
      };

      garmin.enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the SparkyFitness Garmin microservice.";
      };

      extraEnvironment = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Additional environment variables passed to the backend.";
      };
    };

    config = mkIf cfg.enable {
      modules.acme.certs.${cfg.fqdn.acmeHost}.aliases = [cfg.fqdn.dn];

      sops.secrets."${serviceName}/secrets.env" = {
        sopsFile = cfg.secretsFile;
        mode = "0400";
        format = "dotenv";
        owner = "sparkyfitness";
        group = "sparkyfitness";
      };

      services = {
        nginx.virtualHosts.${cfg.fqdn.dn} = {
          forceSSL = true;
          useACMEHost = cfg.fqdn.acmeHost;
        };

        sparkyfitness = {
          enable = true;
          inherit (cfg) port stateDir extraEnvironment;
          frontendUrl = "https://${cfg.fqdn.dn}";
          environmentFile = config.sops.secrets."${serviceName}/secrets.env".path;

          database.createLocally = true;
          nginx.virtualHost = cfg.fqdn.dn;

          garmin.enable = cfg.garmin.enable;
        };
      };
    };
  };
}
