# as of nextcloud 32, AppAPI plugin is installed automatically.
# this requires some deploy daemon.
# harp is the recommendet option.
# ~ https://docs.nextcloud.com/server/stable/admin_manual/exapps_management/AppAPIAndExternalApps.html
# ~ https://help.nextcloud.com/t/appapi-default-deploy-daemon-is-not-set/233859/15
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.nextcloud;
  serviceName = "appapi-harp";
in {
  options.modules.nextcloud.harp = {
    enable = mkEnableOption "HaRP";
    environmentFile = mkOption {
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    # requires docker.
    # ~ https://github.com/nextcloud/HaRP?tab=readme-ov-file#how-to-install-it
    modules.docker.enable = true;

    sops.secrets = {
      "${serviceName}/secrets" = {
        sopsFile = cfg.harp.environmentFile;
        owner = "root";
        group = "root";
        mode = "0400";
        format = "binary";
      };
    };

    virtualisation.oci-containers = {
      backend = "docker";

      # https://mynixos.com/options/virtualisation.oci-containers.containers.%3Cname%3E
      # https://github.com/nextcloud/HaRP?tab=readme-ov-file#how-to-install-it
      containers.${serviceName} = {
        environment = {NC_INSTANCE_URL = "https://${cfg.primaryFqdn}";};
        environmentFiles = [config.sops.secrets."${serviceName}/secrets".path];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "/root/certs:/certs"
        ];
        hostname = "appapi-harp";
        ports = [
          "8780:8780"
          "8782:8782"
        ];
        image = "ghcr.io/nextcloud/nextcloud-appapi-harp:release";
      };
    };

    services = {
      nginx.virtualHosts."${cfg.primaryFqdn}" = {
        locations."/exapps/" = {
          proxyPass = "http://127.0.0.1:8780";
          extraConfig =
            # nginx
            ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
        };
      };
    };
  };
}
