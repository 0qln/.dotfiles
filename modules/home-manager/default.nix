{
  specialArgs,
  inputs,
  pkgs,
  config,
  ...
}:
let
  utils = import ./utils;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager.useGlobalPkgs = false;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = specialArgs // { inherit utils; };
}
