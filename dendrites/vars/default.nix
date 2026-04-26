{...}: {
  flake.nixosModules.vars = {...}: {
    imports = [
      ./nixos-options.nix
      ./nixos-defaults.nix
    ];
  };

  flake.homeModules.vars = {...}: {
    imports = [
      ./hm-options.nix
      ./hm-defaults.nix
    ];
  };
}
