{flake, ...}: {
  imports = [
    ../_common
    flake.nixosModules."wsl"
  ];

  users = {
    root.enable = true;
    oq.enable = true;
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
}
