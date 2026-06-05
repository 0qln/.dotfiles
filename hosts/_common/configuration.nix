{
  inputs,
  flake,
  host-name,
  ...
}: {
  imports = [
    ../../modules
    ../../home/users

    ./localization.nix
    ./printing.nix
    ./packages.nix
    ./smart-card-daemon.nix
    ./app-image.nix
    ./compat.nix

    flake.nixosModules.nix
    flake.nixosModules.utils
    flake.nixosModules.vars
  ];

  networking.hostName = host-name;

  nixpkgs = {
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
