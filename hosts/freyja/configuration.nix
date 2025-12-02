{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # inputs.private.nixosModules."lif"

    ../_common/configuration.nix

    # ./bluetooth.nix
    ./configuration-init.nix
    # ./packages.nix

    ../../home/users/oq
    ../../home/users/root

    ../../modules/battery
    ../../modules/avahi
    ../../modules/home-manager
    ../../modules/hypr
    ../../modules/sops
    ../../modules/ydotool

    # todo: fix wireguard vpn
    # (import ../../modules/wireguard/template.nix {
    #   ip = "10.100.0.2/32";
    #   privateKeyFile = ./wireguard/0qln/private.key.secrets;
    #   serverAddress = config.vars.fqdns.primary.dn;
    #   serverPubKey = builtins.readFile ../lifbrasir/wireguard/0qln/public.key;
    #   vpnName = "0qln";
    # })
  ];

  modules = {
    battery.enable = true;
    avahi.enable = true;
    hypr.enable = true;
    ydotool.enable = true;
  };

  sops = {
    enable = true;
    # todo: improve yubi key integration and use it.
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

  home-manager = {
    users.oq = _: {
      imports = [./home-vars.nix];
      settings = {
        enable = true;
        uiEnv = "gui";
      };
      modules = {
        nixvim.wayland.enable = true;
        hypr.enable = true;
        browser = {
          firefox = {
            tor.enable = false;
            zen = {
              enable = true;
              setDefault = true;
            };
          };
        };
        zoom.enable = false;
        kooha.enable = false;
        jetbrains = {
          enable = false;
        };
        minecraft = {
          prismlauncher.enable = false;
        };
      };
      private = {
        secrets.ssh = {
          server = true;
        };
      };
    };

    users.root = _: {
      settings = {
        enable = true;
        uiEnv = "gui";
      };
    };
  };
}
