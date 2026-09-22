{
  inputs,
  self,
  ...
}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.odoo = {config, ...}: let
    cfg = config.modules.odoo;
  in {
    options.modules.odoo = {
      enable = mkEnableOption "Odoo distrobox system dependencies";
    };

    imports = [
      self.nixosModules.distrobox
    ];

    config = mkIf cfg.enable {
      modules.distrobox.enable = true;
    };
  };

  flake.homeModules.odoo = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.modules.odoo;
    containerName = "odoo_ubuntu";
    containerHome = "${config.home.homeDirectory}/.distrobox/${containerName}";
    inherit (config.home) username;
  in {
    options.modules.odoo = {
      enable = mkEnableOption "odoo";
      containerName = mkOption {
        type = types.str;
        default = "odoo_ubuntu";
        description = "Name of the distrobox container running Odoo.";
      };
      branch = mkOption {
        type = types.str;
        default = "19.0";
        description = "Odoo git branch to clone.";
      };
    };

    imports = [
      self.homeModules.distrobox
    ];

    config = mkIf cfg.enable {
      home.file.".distrobox/${containerName}/odoo.conf" = {
        force = true;
        text =
          # ini
          ''
            [options]
            admin_passwd = admin_passwd
            db_host = 127.0.0.1
            db_port = 5432
            db_user = odoo
            db_password = odoo
            xmlrpc_port = 9026
            netrpc_port = 9026
            http_port = 9026
            dev_mode = all
          '';
      };

      home.file.".distrobox/${containerName}/bin/odoo-wrap" = {
        executable = true;
        force = true;
        text =
          # bash
          ''
            #!/usr/bin/env bash

            set -euo pipefail

            ODOO_DIR="$HOME/repos/odoo"
            ENTERPRISE_DIR="$HOME/repos/enterprise"
            WS_DIR="$HOME/repos/ws-odoo"
            CONF="$HOME/odoo.conf"
            DB="''${ODOO_DB:-odoo_dev}"

            sudo service postgresql start >/dev/null

            # workspace addons live either at the workspace root
            # (worksimple_project/__manifest__.py) or one level down inside a
            # submodule that bundles several (ecoservice/eco_base/__manifest__.py),
            # so the addons path is the set of directories holding a manifest.
            ws_manifest_dirs() {
              find "$WS_DIR" -mindepth 2 -maxdepth 3 -name __manifest__.py -printf '%h\n' | sort -u
            }

            ADDONS_PATH="$(
              {
                printf '%s\n' "$ODOO_DIR/odoo/addons" "$ODOO_DIR/addons" "$ENTERPRISE_DIR"
                ws_manifest_dirs | xargs -r -n1 dirname | sort -u
              } | paste -sd, -
            )"

            echo "database:    $DB" >&2
            echo "config:      $CONF" >&2
            echo "addons path: $ADDONS_PATH" >&2
            echo "ws modules:  $(ws_manifest_dirs | xargs -r -n1 basename | sort -u | paste -sd, -)" >&2

            exec python3 "$ODOO_DIR/odoo-bin" \
              --config="$CONF" \
              --addons-path="$ADDONS_PATH" \
              --database="$DB" \
              "$@"
          '';
      };

      home.file.".distrobox/${containerName}/start-odoo.sh" = {
        executable = true;
        force = true;
        text =
          # bash
          ''
            #!/usr/bin/env bash
            exec "$HOME/bin/odoo-wrap" "$@"
          '';
      };

      home.activation = {
        odoo-distrobox-config_ssh = config.utils.mkCopy {
          source = "${config.home.homeDirectory}/.ssh";
          destPath = "${containerHome}/.ssh";
          newMode = "700";
          deps = ["mutableFileGeneration" "writeBoundary"];
        };

        odoo-distrobox-config_git = config.utils.mkCopy {
          source = "${config.xdg.configHome}/git";
          destPath = "${containerHome}/.config/git";
          newMode = "700";
          deps = ["mutableFileGeneration" "writeBoundary"];
        };

        odoo-distrobox-config_gh = config.utils.mkCopy {
          source = "${config.xdg.configHome}/gh";
          destPath = "${containerHome}/.config/gh";
          newMode = "700";
          deps = ["mutableFileGeneration" "writeBoundary"];
        };
      };

      home.file.".distrobox/${containerName}/setup-container.sh" = {
        executable = true;
        force = true;
        text =
          # bash
          ''
            #!/usr/bin/env bash

            set -e

            sudo apt-get update -y

            # install prerequisites (debinstall.sh handles the rest)
            sudo apt-get install -y \
              git \
              curl \
              postgresql \
              postgresql-client \
              python3-pip \
              nodejs \
              npm

            # set up postgresql. note sudoers only grants root, not postgres,
            # so postgres commands have to go through `sudo su postgres`.
            sudo service postgresql start
            sudo su postgres -c "createuser -d -R -S ${username}" 2>/dev/null || true
            createdb ${username} 2>/dev/null || true

            # the role odoo.conf authenticates as. it owns the dev databases, so
            # that odoo can see its own tables in information_schema.
            sudo su postgres -c "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='odoo'\"" | grep -q 1 \
              || sudo su postgres -c "psql -c \"CREATE ROLE odoo LOGIN CREATEDB PASSWORD 'odoo'\""

            # configure git credentials for HTTPS clones (e.g. private enterprise repo)
            # the host uses `gh auth git-credential` via a nix-store path that does not
            # exist inside the container, so derive a plain credential store from the
            # copied gh token instead.
            gh_hosts="$HOME/.config/gh/hosts.yml"
            if [ -f "$gh_hosts" ]; then
              gh_token="$(grep -m1 'oauth_token:' "$gh_hosts" | awk '{print $2}')"
              if [ -n "$gh_token" ]; then
                printf 'https://x-access-token:%s@github.com\n' "$gh_token" > "$HOME/.git-credentials"
                chmod 600 "$HOME/.git-credentials"
                # drop the broken host credential helpers pointing to the nix store
                git config --global --unset-all 'credential.https://github.com.helper' 2>/dev/null || true
                git config --global --unset-all 'credential.https://gist.github.com.helper' 2>/dev/null || true
                git config --global --replace-all credential.helper store
              fi
            fi

            # clone odoo source if not already present
            if [ ! -d "${containerHome}/repos/odoo" ]; then
              mkdir -p "${containerHome}/repos"
              git clone \
                --branch ${cfg.branch} \
                --single-branch \
                https://github.com/odoo/odoo.git \
                "${containerHome}/repos/odoo"
            fi

            if [ ! -d "${containerHome}/repos/enterprise" ]; then
              mkdir -p "${containerHome}/repos"
              git clone \
                --branch ${cfg.branch} \
                --single-branch \
                https://github.com/odoo/enterprise.git \
                "${containerHome}/repos/enterprise"
            fi

            # the worksimple addon workspace. its submodules are cloned over ssh,
            # which works because ~/.ssh is copied into the container home.
            if [ ! -d "${containerHome}/repos/ws-odoo" ]; then
              mkdir -p "${containerHome}/repos"
              git clone \
                --branch staging \
                --recurse-submodules \
                https://github.com/workSimple-GmbH/odoo \
                "${containerHome}/repos/ws-odoo"
            fi

            # install odoo python/system dependencies
            cd "${containerHome}/repos/odoo"
            sudo ./setup/debinstall.sh

            # inotify powers the code autoreload that `dev_mode = all` turns on
            sudo apt-get install -y python3-inotify

            # python dependencies of the workspace addons. ubuntu marks its python
            # as externally managed, hence --break-system-packages into ~/.local.
            pip3 install --break-system-packages --user \
              -r "${containerHome}/repos/ws-odoo/requirements.txt"

            # add ~/bin to PATH
            if ! grep -qF 'PATH="$HOME/bin:$PATH"' ~/.bashrc; then
              echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
            fi
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
