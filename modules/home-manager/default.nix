{extraArgs ? {}}: {
  inputs,
  vars, # NOTICE: if this is
  ...
}: {
  imports = with inputs; [
    home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = false;
    useUserPackages = true;
    extraSpecialArgs =
      {
        inherit vars;
      }
      // extraArgs;
  };
}
