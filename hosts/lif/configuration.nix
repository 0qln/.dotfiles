{ ... }:
{
  imports = [
    ../_common

    ./bootloader.nix
    ./mount.nix
    ./bluetooth.nix
    ./glorious-model-o.nix
    ./packages.nix

    ../../home/oq/default.gui.nix

    ../../modules/hypr

    (import ../../services/flake-upgrader {
      flakeDir = "/home/oq/.dotfiles";
      mode = "boot";
    })

    (import ../../services/nixos-garbage-disposal {
    })

    ./sops.nix

    (import ../../modules/wireguard/unicorns {
      configFile = ./wireguard/unicorns/secrets.unicorns;
    })

    ../../modules/ydotool

    # tmp:
    ./starship.nix
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}
