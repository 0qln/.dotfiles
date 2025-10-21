{extraArgs ? {}}: {
  specialArgs,
  inputs,
  pkgs,
  flake,
  vars,
  ...
}: {
  imports = with inputs; [
    home.nixosModules."oq"
    home.nixosModules."root"
    home-manager.nixosModules.home-manager
    nur.modules.nixos.default
  ];

  home-manager = {
    useGlobalPkgs = false;
    useUserPackages = true;
    extraSpecialArgs =
      {
        nixosArgs = specialArgs;
        inherit flake;
        inherit vars;
        inherit (pkgs) nur;
      }
      // extraArgs;
  };
}
