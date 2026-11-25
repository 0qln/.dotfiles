{
  inputs,
  self,
  ...
}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.checkmk = {config, ...}: let
    cfg = config.modules.checkmk;
  in {
    options.modules.checkmk = {
      enable = mkEnableOption "Checkmk distrobox system dependencies";
    };

    imports = [
      self.nixosModules.distrobox
    ];

    config = mkIf cfg.enable {
      modules.distrobox.enable = true;
    };
  };

  flake.homeModules.checkmk = {config, ...}: let
    cfg = config.modules.checkmk;
    inherit (cfg) containerName site;
    containerHome = "${config.home.homeDirectory}/.distrobox/${containerName}";
    package = "check-mk-community-${cfg.version}_0.noble_amd64.deb";
    api = "http://localhost:${toString cfg.port}/${site}/check_mk/api/1.0";
  in {
    options.modules.checkmk = {
      enable = mkEnableOption "checkmk";
      containerName = mkOption {
        type = types.str;
        default = "checkmk_ubuntu";
        description = "Name of the distrobox container running Checkmk.";
      };
      version = mkOption {
        type = types.str;
        # the version of the production site, so that the REST API and the
        # notification context behave the same here.
        default = "2.5.0p16";
        description = "Checkmk Community version to install.";
      };
      site = mkOption {
        type = types.str;
        # deliberately not the production site's name, so that whatever
        # takes the site from its configuration gets tried with another one.
        default = "dev";
        description = "Name of the Checkmk site.";
      };
      port = mkOption {
        type = types.port;
        default = 8095;
        description = "Port of the container's system apache, the one the browser and the REST API use.";
      };
      sitePort = mkOption {
        type = types.port;
        # distrobox shares the host's network, and the site apache's default
        # of 5000 is a common development port.
        default = 5095;
        description = "Port of the site's own apache, behind the system apache.";
      };
    };

    imports = [
      self.homeModules.distrobox
    ];

    config = mkIf cfg.enable {
      home.file.".distrobox/${containerName}/bin/checkmk-wrap" = {
        executable = true;
        force = true;
        text =
          # bash
          ''
            #!/usr/bin/env bash

            set -euo pipefail

            case "''${1:-start}" in
              start)
                sudo service apache2 start >/dev/null
                # omd start exits 2 when the site is already running.
                sudo omd start ${site} || true
                echo "web:         http://localhost:${toString cfg.port}/${site}/ (cmkadmin / cmkadmin)" >&2
                ;;
              stop)
                sudo omd stop ${site} || true
                sudo service apache2 stop >/dev/null || true
                ;;
              info)
                # the two settings files of WorkSimple.MonitoringBroker, for a
                # local broker; BROKER_* come from that broker.
                cat <<INFO
            web:      http://localhost:${toString cfg.port}/${site}/ (cmkadmin / cmkadmin)
            rest api: ${api}

            resync job (.env):
              CHECKMK_SITE=${site}
              CHECKMK_API_URL=${api}
              CHECKMK_USER=broker
              CHECKMK_SECRET=broker-dev-secret

            notification plugin (/omd/sites/${site}/etc/monitoring-broker.env):
              CHECKMK_API_URL=${api}
              CHECKMK_USER=broker
              CHECKMK_SECRET=broker-dev-secret
            INFO
                ;;
              install-plugin)
                # runs the checkout's own installer as the site user, the way
                # the README has it for the production site.
                checkout="$(realpath "''${2:?usage: checkmk-wrap install-plugin <WorkSimple.MonitoringBroker checkout>}")"
                sudo su - ${site} -c "$checkout/scripts/install-checkmk-plugin.sh"
                ;;
              *)
                echo "usage: checkmk-wrap [start|stop|info|install-plugin <checkout>]" >&2
                exit 1
                ;;
            esac
          '';
      };

      home.file.".distrobox/${containerName}/setup-container.sh" = {
        executable = true;
        force = true;
        text =
          # bash
          ''
            #!/usr/bin/env bash

            set -euo pipefail

            # init_hooks run as root on every start of the container, so every
            # step below checks first whether it is already done.
            if ! command -v omd >/dev/null; then
              apt-get update -y
              apt-get install -y curl ca-certificates
              curl -fsSL -o /tmp/${package} https://download.checkmk.com/checkmk/${cfg.version}/${package}
              apt-get install -y /tmp/${package}
              rm -f /tmp/${package}
            fi

            # the package's apache listens on 80, which a rootless container
            # sharing the host's network cannot bind.
            sed -i 's/^Listen 80$/Listen ${toString cfg.port}/' /etc/apache2/ports.conf
            echo 'ServerName localhost' > /etc/apache2/conf-available/servername.conf
            a2enconf -q servername

            # --no-tmpfs: a rootless container cannot mount the tmpfs omd
            # wants for the site's tmp.
            if ! omd sites --bare | grep -qx ${site}; then
              omd create --no-tmpfs --admin-password cmkadmin ${site}
              omd config ${site} set APACHE_TCP_PORT ${toString cfg.sitePort}
              # `omd config` leaves the system apache's proxy to the site on
              # the old port; this rewrites it.
              omd update-apache-config ${site}
            fi

            service apache2 start
            omd start ${site} || true

            # an automation user like the production one (Houston Issue 15943):
            # the guest role reads every host and service and writes nothing.
            # a host as well, because the resync job takes an empty host list
            # for a failure.
            marker=/omd/sites/${site}/.monitoring-broker-provisioned
            if [ ! -e "$marker" ]; then
              admin=(-u cmkadmin:cmkadmin -H 'Accept: application/json' -H 'Content-Type: application/json')
              curl -fsS -o /dev/null "''${admin[@]}" -X POST ${api}/domain-types/user_config/collections/all \
                -d '{"username": "broker", "fullname": "Monitoring broker (dev)", "auth_option": {"auth_type": "automation", "secret": "broker-dev-secret"}, "roles": ["guest"]}'
              curl -fsS -o /dev/null "''${admin[@]}" -X POST ${api}/domain-types/host_config/collections/all \
                -d '{"folder": "/", "host_name": "localhost", "attributes": {"ipaddress": "127.0.0.1"}}'
              curl -fsS -o /dev/null "''${admin[@]}" -H 'If-Match: *' -X POST ${api}/domain-types/activation_run/actions/activate-changes/invoke \
                -d '{"redirect": false, "sites": ["${site}"], "force_foreign_changes": true}'
              touch "$marker"
            fi

            # `distrobox enter -- cmd` runs no profile, so the wrapper goes
            # where the stock PATH looks; the link survives a new home-manager
            # generation because it points at the stable ~/bin path.
            ln -sf "${containerHome}/bin/checkmk-wrap" /usr/local/bin/checkmk-wrap

            echo "Checkmk ${cfg.version} site ${site}: http://localhost:${toString cfg.port}/${site}/ (checkmk-wrap info)"
          '';
      };

      home.file.".config/distrobox/distrobox.ini".text =
        # ini
        ''
          [${containerName}]
          image=docker.io/library/ubuntu:24.04
          pull=true
          home=${containerHome}

          init_hooks=${containerHome}/setup-container.sh
        '';
    };
  };
}
