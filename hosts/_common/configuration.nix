{
  inputs,
  flake,
  ...
}: {
  imports = [
    ../../modules
    ../../home/users

    ./localization.nix
    ./networking.nix
    ./printing.nix
    ./packages.nix
    ./smart-card-daemon.nix
    ./app-image.nix
    ./compat.nix

    flake.nixosModules.nix
    flake.nixosModules.utils
    flake.nixosModules.vars
  ];

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.nur.overlays.default
      inputs.cartograph-cf.overlays.default
    ];
  };

  modules = {
    devenv = {
      enable = true;
      caches.enable = true;
    };
    ssh.enable = true;
  };
}
