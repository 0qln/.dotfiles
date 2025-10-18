{...}: {
  imports = [
    ../_common/configuration.nix

    ./hosts.nix
    ./bootloader.nix
    ./mount.nix
    ./bluetooth.nix
    ./glorious-model-o.nix
    ./packages.nix
    ./nvidia.nix
    ./intel.nix

    ../../modules/hypr
    ../../modules/ydotool
    ../../modules/steam
    ../../modules/doh
    ../../modules/sops

    (import ../../modules/home-manager {
      extraArgs = {
        monitors = import ./monitors.nix {};
      };
    })

    (import ../../services/flake-upgrader {
      flakeDir = "/home/oq/.dotfiles";
      mode = "boot";
    })

    (import ../../services/nixos-garbage-disposal {
      })

    (import ../../modules/wireguard/unicorns {
      configFile = ./wireguard/unicorns/secrets.unicorns;
    })

    # (import ../../modules/wireguard/0qln {
    #   ip = "10.100.0.2/32";
    #   privateKeyFile = ./wireguard/0qln/private.key.secrets;
    #   serverAddress = "0qln.duckdns.org";
    #   serverPubKey = builtins.readFile ../lifbrasir/wireguard/0qln/public.key;
    # })

    # tmp:
    ./starship.nix
  ];

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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}
