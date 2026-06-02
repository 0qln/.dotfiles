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

            # install odoo python/system dependencies
            cd "${containerHome}/repos/odoo"
            sudo ./setup/debinstall.sh

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
