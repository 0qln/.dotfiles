{inputs, ...}: {
  imports = [
    ../../modules
    ../../home/users

    ./localization.nix
    ./networking.nix
    ./printing.nix
    ./packages.nix
    ./vars.nix
    ./smart-card-daemon.nix
    ./app-image.nix
    ./compat.nix
  ];

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.nur.overlays.default
      inputs.cartograph-cf.overlays.default
    ];
  };

  modules = {
    nix = {
      enable = true;
      flakes.enable = true;
    };
    devenv = {
      enable = true;
      caches.enable = true;
    };
    ssh.enable = true;
  };
}
