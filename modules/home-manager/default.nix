{
  pkgs,
  pkgs-citrix,
  config,
  inputs,
  ...
}: {
  imports = with inputs; [
    home-manager.nixosModules.home-manager
  ];

  home-manager = let
    configuration = import ./config.nix {
      inherit (pkgs) nur;
      inherit pkgs-citrix;
      inherit inputs;
      inherit config;
    };
  in
    configuration
    // {
      useGlobalPkgs = false;
      useUserPackages = true;
    }
    // {
      # TODO: remove when pr is merged (see comment in ./config.nix)
      backupFileExtension = config.vars.home.config.backup.extension;
    };
}
