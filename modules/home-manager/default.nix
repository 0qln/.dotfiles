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
      backupExtension = config.vars.home.config.backup.extension;
      inherit (pkgs) nur;
      inherit pkgs-citrix;
      inherit inputs;
    };
  in
    configuration;
}
