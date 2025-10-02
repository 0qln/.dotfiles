{extraArgs}: {
  specialArgs,
  inputs,
  pkgs,
  vars,
  ...
}: let
  utils = import ./utils;
  backupExtension = "hm-bac";
in {
  imports = with inputs; [
    home-manager.nixosModules.home-manager
    nur.modules.nixos.default
  ];

  home-manager = {
    useGlobalPkgs = false;
    useUserPackages = true;
    extraSpecialArgs =
      specialArgs
      // {
        inherit (pkgs) nur;
        inherit utils;
        inherit backupExtension;
      }
      // extraArgs;
    backupFileExtension = backupExtension;
  };
}
