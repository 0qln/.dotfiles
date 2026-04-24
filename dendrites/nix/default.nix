{inputs, ...}: {
  # todo: also move other nix config here

  flake.nixosModules.nix = {...}: {
    config = {
      modules = {
        nix = {
          enable = true;
          flakes.enable = true;
        };
      };
    };
  };

  flake.homeModules.nix = {...}: {
    imports = [
      inputs.nix-index-database.homeModules.default
    ];

    programs.nix-index-database.comma.enable = true;
  };
}
