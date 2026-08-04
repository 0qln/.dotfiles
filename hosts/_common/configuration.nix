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
    ./app-image.nix
    ./compat.nix

    flake.nixosModules.nix
    flake.nixosModules.utils
    flake.nixosModules.vars
    flake.nixosModules.yubi
  ];

  networking.hostName = host-name;

  nixpkgs = {
    overlays = [
      inputs.nur.overlays.default
      inputs.cartograph-cf.overlays.default
      inputs.angel-wish.overlays.default
      inputs.ruritania.overlays.default
      inputs.kingjola.overlays.default
    ];
  };

  modules = {
    devenv = {
      enable = true;
      caches.enable = true;
    };

    ssh.enable = true;

    yubi.enable = true;
  };
}
