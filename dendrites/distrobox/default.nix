{inputs, ...}:
with inputs.nixpkgs.lib; {
  # --- SYSTEM CONFIGURATION ---
  flake.nixosModules.distrobox = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.modules.distrobox;
  in {
    options.modules.distrobox = {
      enable = mkEnableOption "distrobox system dependencies";
    };

    config = mkIf cfg.enable {
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
      };

      environment.systemPackages = [
        pkgs.distrobox
      ];
    };
  };

  # --- USER CONFIGURATION ---
  flake.homeModules.distrobox = {config, ...}: let
    cfg = config.modules.distrobox;
    containerHome = "${config.home.homeDirectory}/.distrobox/arch-dev";
    username = config.home.username;
  in {
    options.modules.distrobox = {
      enable = mkEnableOption "distrobox user containers";
    };

    config = mkIf cfg.enable {
      # 1. CREATE A CLEAN, READABLE PROVISIONING SCRIPT
      # This file drops directly into the container's isolated home directory.
      home.file.".distrobox/arch-dev/setup-container.sh" = {
        executable = true;
        text =
          # bash
          ''
            #!/usr/bin/env bash
            # This script runs automatically as root inside the container during boot.
            set -e # Exit immediately if a command fails

            echo "=== Starting Declarative Container Setup ==="

            # 1. Initialize Pacman keys if missing
            if [ ! -d /etc/pacman.d/gnupg ]; then
              echo "=> Initializing Pacman keyring..."
              pacman-key --init
              pacman-key --populate archlinux
            fi

            # 2. Keep core developer packages cleanly listed and updated
            echo "=> Syncing system packages..."
            pacman -Sy --needed --noconfirm \
              code \
              git \
              base-devel \
              xdg-utils \
              nix \
              gnome-keyring \
              libsecret

            # 3. Patch VS Code directory permissions for UI modification extensions
            if [ -d /usr/lib/code ]; then
              echo "=> Granting ${username} ownership of VS Code binaries..."
              chown -R ${username}:${username} /usr/lib/code
            fi

            # 4. Safely hook the Nix profile into the system-wide interactive shell
            if ! grep -qF '. /etc/profile.d/nix.sh' /etc/bash.bashrc; then
              echo "=> Sourcing Nix profile in /etc/bash.bashrc..."
              echo '. /etc/profile.d/nix.sh' >> /etc/bash.bashrc
            fi

            echo "=== Container Setup Complete! ==="
          '';
      };

      # 2. DEFINE THE CLEANED-UP DISTROBOX INI Manifest
      home.file.".config/distrobox/distrobox.ini".text =
        # ini
        ''
          [arch-dev]
          image=archlinux:latest
          pull=true
          home=${containerHome}
          volume=/nix/store:/nix/store:ro

          # Points cleanly to the script Home Manager dropped into the home folder
          init_hooks=/run/host/home/${username}/.distrobox/arch-dev/setup-container.sh

          exported_apps=code
        '';
    };
  };
}
