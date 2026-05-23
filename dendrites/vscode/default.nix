{
  inputs,
  self,
  ...
}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.vscode = {config, ...}: let
    cfg = config.modules.vscode;
  in {
    options.modules.vscode = {
      enable = mkEnableOption "VSCode system dependencies";
    };

    imports = [
      self.nixosModules.distrobox
    ];

    config = mkIf cfg.enable {
      modules.distrobox.enable = true;
    };
  };

  flake.homeModules.vscode = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.modules.vscode;
    containerName = "vscode_fedora";
    containerHome = "${config.home.homeDirectory}/.distrobox/${containerName}";
    inherit (config.home) username;
  in {
    options.modules.vscode = {
      enable = mkEnableOption "vscode";
    };

    imports = [
      ./profiles/default.nix
      ./profiles/kimai.nix
      ./profiles/odoo.nix
      ./profiles/odoo.kanagawa.nix
      ./profiles/clanker.kanagawa.nix
      ./fixes/mutability.nix
      ./fixes/extensions.nix
    ];

    config = mkIf cfg.enable {
      programs.vscode = {
        enable = true;

        # provide a dummy package so it doesn't install the real one, we just
        # want to use the file generation stuff
        package = pkgs.runCommand "vscode-dummy" {
          pname = "vscode";
          version = "dummy";
        } "mkdir $out";
      };

      home.activation = {
        vscode-distrobox-config_ssh = config.utils.mkCopy {
          source = "${config.home.homeDirectory}/.ssh";
          destPath = "${containerHome}/.ssh";
          newMode = "700";
          deps = ["mutableFileGeneration" "writeBoundary"];
        };

        vscode-distrobox-config_git = config.utils.mkCopy {
          source = "${config.xdg.configHome}/git";
          destPath = "${containerHome}/.config/git";
          newMode = "700";
          deps = ["mutableFileGeneration" "writeBoundary"];
        };

        vscode-distrobox-config_vscode = config.utils.mkCopy {
          source = "${config.xdg.configHome}/Code/User";
          destPath = "${containerHome}/.config/Code/User";
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

            # other packages
            sudo dnf install -y gnome-keyring
            sudo dnf install -y libsecret

            # install vscode
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
            sudo dnf check-update --refresh
            sudo dnf install -y code

            # patch permissions so extensions can mutate the js source files
            if [ -d /usr/share/code ] && [ "$(stat -c '%U' /usr/share/code)" != "${username}" ]; then
              echo "=> Granting ${username} ownership of VS Code binaries..."
              chown -R ${username}:${username} /usr/share/code
            fi

            # link dev tools to host
            ## nvim
            sudo tee /usr/bin/nvim << 'EOF' > /dev/null
            #!/bin/bash
            HOST_PWD="''${PWD#/run/host}"
            (cd "$HOST_PWD" && /usr/bin/distrobox-host-exec nvim "$@")
            EOF
            sudo chmod +x /usr/bin/nvim

            ## git
            sudo tee /usr/bin/git << 'EOF' > /dev/null
            #!/bin/bash
            HOST_PWD="''${PWD#/run/host}"
            (cd "$HOST_PWD" && /usr/bin/distrobox-host-exec git "$@")
            EOF
            sudo chmod +x /usr/bin/git

            ## nix
            sudo tee /usr/bin/nix << 'EOF' > /dev/null
            #!/bin/bash
            HOST_PWD="''${PWD#/run/host}"
            (cd "$HOST_PWD" && /usr/bin/distrobox-host-exec nix "$@")
            EOF
            sudo chmod +x /usr/bin/nix

            ## nix-shell
            sudo tee /usr/bin/nix-shell << 'EOF' > /dev/null
            #!/bin/bash
            HOST_PWD="''${PWD#/run/host}"
            (cd "$HOST_PWD" && /usr/bin/distrobox-host-exec nix-shell "$@")
            EOF
            sudo chmod +x /usr/bin/nix-shell
          '';
      };

      home.file.".config/distrobox/distrobox.ini".text =
        # ini
        ''
          [${containerName}]
          pull=true
          volume=/nix/store:/nix/store:ro
          home=${containerHome}

          init_hooks=${containerHome}/setup-container.sh
          exported_apps=code
        '';
    };
  };
}
