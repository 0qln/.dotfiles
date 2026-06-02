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

    # todo: move this to auto import in the flake when the dendritese are discovered
    flake.nixosModules.hyprland-opts
    flake.nixosModules.xdg-opts
  ];

  # todo: s.a.
  home-manager = {
    users.oq = _: {
      imports = [
        flake.homeModules.hyprland-opts
        flake.homeModules.hyprland-mods-opts
        flake.homeModules.xdg-opts
      ];
    };
  };

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
