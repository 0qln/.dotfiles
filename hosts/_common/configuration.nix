{...}: {
  imports = [
    ../../modules/avahi
    ../../modules/ssh
    ../../modules/nix
    ../../modules/devenv

    ./localization.nix
    ./networking.nix
    ./printing.nix
    ./packages.nix
    ./vars.nix
    ./smart-card-daemon.nix
    ./app-image.nix
    ./compat.nix
  ];

  modules = {
    nix = {
      flakes.enable = true;
    };
    devenv = {
      caches.enable = true;
    };
  };
}
