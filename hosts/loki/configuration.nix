{
  config,
  flake,
  lib,
  ...
}: {
  imports = [
    ../_common
    flake.nixosModules."wsl"
  ];

  users = {
    root.enable = true;
    oq.enable = true;
  };

  users.users.oq = {
    # Keep user@<uid>.service running at all times (even without a login
    # session) so the D-Bus session socket is always present. Without this,
    # switch-to-configuration's "reloading user units" step fails when the
    # user is not currently logged in.
    linger = true;
  };

  # Ensure the home-manager activation service can reach the user's D-Bus
  # session bus. Without this, tools that depend on D-Bus (xdg-mime, systemctl
  # --user, etc.) intermittently fail with "Unable to autolaunch a dbus-daemon
  # without a $DISPLAY for X11" when nixos-rebuild switch is run outside of an
  # active graphical session.
  systemd.services."home-manager-oq" = {
    after = ["user@${toString config.users.oq.uuid}.service"];
    wants = ["user@${toString config.users.oq.uuid}.service"];
    environment.DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/${toString config.users.oq.uuid}/bus";
  };

  modules = {
    wsl = {
      enable = true;
      defaultUser = "oq";
    };
    home-manager.enable = true;
  };

  home-manager = {
    users.oq = _: {
      imports = [
        ./home-vars.nix
      ];
      settings = {
        enable = true;
        uiEnv = "wsl";
      };
      private = {
        secrets.ssh = {
          server = true;
        };
      };
    };
  };

  sops = {
    enable = true;
    # TODO: improve yubi key integration and use it.
    enableYubikeyIntegration = false;
    identities = [
      {
        name = "oq.age";
        file = "/home/oq/.config/sops/age/keys.txt";
      }
    ];
    yubiIdentities = [
      rec {
        name = "yubi-1/age-yubikey-identity-ca0b293d.txt";
        file = ../../yubis/${name};
      }
      rec {
        name = "yubi-2/age-yubikey-identity-7432b76e.txt";
        file = ../../yubis/${name};
      }
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
