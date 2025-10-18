{extraArgs}: {
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

  home-manager.users.oq = {...}: {
    settings = {
      uiEnv = "gui";
    };
  };

  home-manager.users.root = _: {
    settings = {
      uiEnv = "gui";
    };
  };

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
