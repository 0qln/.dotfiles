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
    flake.nixosModules.fonts
  ];

  networking.hostName = host-name;

  nixpkgs = {
    overlays = [
      inputs.nur.overlays.default
    ];
  };

  modules = {
    devenv = {
      enable = true;
      caches.enable = true;
    };

    ssh.enable = true;

    yubi.enable = true;

    fonts.enable = true;
  };
}
