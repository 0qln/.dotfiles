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

  flake.homeModules.nix = {pkgs, ...}: {
    imports = [
      inputs.nix-index-database.homeModules.default
    ];

    config = {
      programs.nix-index-database.comma.enable = true;

      home.packages = with pkgs; [
        nurl
        nix-init
      ];
    };
  };
}
