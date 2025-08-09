{
  specialArgs,
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager.useGlobalPkgs = false;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = specialArgs // {
    sysConfig = config;
  };
}
