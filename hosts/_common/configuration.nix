{...}: {
  imports = [
    ../../modules/avahi
    ../../modules/ssh

    ./localization.nix
    ./networking.nix
    ./printing.nix
    ./nix-config.nix
    ./packages.nix
    ./vars.nix
    ./smart-card-daemon.nix
    ./app-image.nix
  ];
}
