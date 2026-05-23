{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.vscode = {config, ...}: let
    cfg = config.modules.vscode;
  in {
    options.modules.vscode = {
      enable = mkEnableOption "VSCode system dependencies";
    };

    imports = [
      inputs.nixosModules.distrobox
    ];

    config = mkIf cfg.enable {
      modules.distrobox.enable = true;
    };
  };

  flake.homeModules.vscode = {config, ...}: let
    cfg = config.modules.vscode;
    containerHome = "${config.home.homeDirectory}/.distrobox/vscode";
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
    ];

    config = mkIf cfg.enable {
      programs.vscode = {
        enable = true;
      };

      home.activation.vscode-distrobox-config = config.utils.mkCopy {
        source = "${config.xdg.configHome}/Code/User";
        destPath = "${containerHome}/.config/Code/User";
        newMode = "700";
        deps = ["mutableFileGeneration"];
      };

      home.file.".distrobox/vscode/setup-container.sh" = {
        executable = true;
        text =
          # bash
          ''
            #!/usr/bin/env bash
            set -e

            echo "=== Starting Declarative Container Setup ==="

            # initialize Pacman keys if missing
            if [ ! -d /etc/pacman.d/gnupg ]; then
              echo "=> Initializing Pacman keyring..."
              pacman-key --init
              pacman-key --populate archlinux
            fi

            # keep core developer packages cleanly listed and updated
            echo "=> Syncing system packages..."
            pacman -Sy --needed --noconfirm \
              code \
              git \
              base-devel \
              xdg-utils \
              nix \
              gnome-keyring \
              libsecret

            # patch VS Code directory permissions for UI modification extensions
            if [ -d /usr/lib/code ]; then
              echo "=> Granting ${username} ownership of VS Code binaries..."
              chown -R ${username}:${username} /usr/lib/code
            fi

            # hook the Nix profile into the system-wide interactive shell
            if ! grep -qF '. /etc/profile.d/nix.sh' /etc/bash.bashrc; then
              echo "=> Sourcing Nix profile in /etc/bash.bashrc..."
              echo '. /etc/profile.d/nix.sh' >> /etc/bash.bashrc
            fi

            echo "=== Container Setup Complete! ==="
          '';
      };

      home.file.".config/distrobox/distrobox.ini".text =
        # ini
        ''
          [vscode]
          image=archlinux:latest
          pull=true
          volume=/nix/store:/nix/store:ro
          home=${containerHome}
          init_hooks=/run/host/home/${username}/.distrobox/vscode/setup-container.sh
          exported_apps=code
        '';
    };
  };
}
