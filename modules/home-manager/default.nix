{
  pkgs,
  pkgs-citrix,
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
      inherit inputs;
      inherit config;
      inherit utilz;
    };
  in
    configuration
    // {
      useGlobalPkgs = false;
      useUserPackages = true;
    };
}
