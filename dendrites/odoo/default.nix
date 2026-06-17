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
      home.file.".distrobox/${containerName}/bin/odoo-wrap" = {
        executable = true;
        force = true;
        text =
          # bash
          ''
            #!/usr/bin/env bash

            WS_DIR="$HOME/odoo-ws"

            ADDONS="$(ls $WS_DIR/*/.git | xargs -n1 dirname)"
            echo "Detected Addons: "
            echo "$ADDONS"

            BASE_ADDONS="$(cat <(echo "$HOME/repos/odoo/addons") <(echo "$HOME/enterprise-${cfg.branch}") <(echo "$HOME/worksimple-${cfg.branch}") <(echo "$WS_DIR"))"
            echo "Base Addons: "
            echo "$BASE_ADDONS"

            FULL_ADDONS="$(cat <(echo "$ADDONS") <(echo "$BASE_ADDONS"))"
            echo "Full Addons: "
            echo "$FULL_ADDONS"

            JOINED_ADDONS="$(echo "$FULL_ADDONS" | paste -sd, - )"
            echo "Joined Addons: "
            echo "$JOINED_ADDONS"

            PLUGINS="$(fd -t d -d 1 . "$WS_DIR" | xargs realpath | xargs -n1 basename)"
            echo "Plugins: "
            echo "$PLUGINS"

            JOINED_PLUGINS="$(echo "$PLUGINS" | xargs -n1 basename | paste -sd, - )"
            echo "Joined: $JOINED_PLUGINS"

            python3 "$HOME/repos/odoo/odoo-bin" "$1" \
                --http-interface=0.0.0.0 \
                --addons-path="$JOINED_ADDONS" \
                -u="$JOINED_PLUGINS" \
                -d db2 -i base
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
              nodejs \
              npm

            # set up postgresql user matching the host user
            sudo service postgresql start
            sudo -u postgres createuser -d -R -S ${username} 2>/dev/null || true
            createdb ${username} 2>/dev/null || true

            # clone odoo source if not already present
            if [ ! -d "${containerHome}/repos/odoo" ]; then
              mkdir -p "${containerHome}/repos"
              git clone \
                --branch ${cfg.branch} \
                --single-branch \
                https://github.com/odoo/odoo.git \
                "${containerHome}/repos/odoo"
            fi

            # clone odoo enterprise if not already present
            if [ ! -d "${containerHome}/enterprise-${cfg.branch}" ]; then
              git clone \
                --branch ${cfg.branch} \
                --single-branch \
                https://github.com/odoo/enterprise.git \
                "${containerHome}/enterprise-${cfg.branch}"
            fi

            # clone workSimple-GmbH/odoo if not already present
            if [ ! -d "${containerHome}/worksimple-${cfg.branch}" ]; then
              git clone \
                --branch ${cfg.branch} \
                --single-branch \
                https://github.com/workSimple-GmbH/odoo.git \
                "${containerHome}/worksimple-${cfg.branch}"
            fi

            # install odoo python/system dependencies
            cd "${containerHome}/repos/odoo"
            sudo ./setup/debinstall.sh

            # install fd-find (used by odoo-wrap)
            sudo apt-get install -y fd-find
            # ubuntu packages fd as fdfind; symlink to fd if not already present
            if ! command -v fd &>/dev/null; then
              sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
            fi

            # add ~/bin to PATH
            if ! grep -qF 'PATH="$HOME/bin:$PATH"' ~/.bashrc; then
              echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
            fi

            # create a convenience start script
            cat > "${containerHome}/start-odoo.sh" << 'EOF'
            #!/usr/bin/env bash
            sudo service postgresql start
            cd "${containerHome}/repos/odoo"
            python3 odoo-bin --addons-path=addons -d odoo_dev "$@"
            EOF
            chmod +x "${containerHome}/start-odoo.sh"
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
