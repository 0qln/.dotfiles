{extraArgs}: {
  specialArgs,
  inputs,
  pkgs,
  config,
  ...
}: let
  utils = import ./utils;
  backupExtension = "hm-bac";
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager.useGlobalPkgs = false;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs =
    specialArgs
    // {
      inherit utils;
      inherit backupExtension;
    }
    // extraArgs;
  home-manager.backupFileExtension = backupExtension;
}
