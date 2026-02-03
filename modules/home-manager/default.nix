{
  pkgs,
  pkgs-citrix,
  pkgs-hot,
  pkgs-stable,
  config,
  inputs,
  utilz,
  ...
}: {
  imports = with inputs; [
    home-manager.nixosModules.home-manager
  ];

  home-manager = let
    configuration = import ./config.nix {
      inherit (pkgs) nur;
      inherit pkgs;
      inherit pkgs-citrix;
      inherit pkgs-hot;
      inherit pkgs-stable;
      inherit inputs;
      inherit config;
      inherit utilz;
    };
  in
    configuration
    // {
      useGlobalPkgs = false;
      useUserPackages = true;
    }
    // (let
      inherit (config.vars.home.config) backup;
    in {
      # todo: move this into ./config.nix when the issue is resolved
      # https://github.com/nix-community/home-manager/issues/5649
      backupFileExtension = backup.extension;
      backupCommand = backup.command;
    });
}
