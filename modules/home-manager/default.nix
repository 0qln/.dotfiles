{extraArgs}: {
  specialArgs,
  inputs,
  pkgs,
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
    modules = {
      firefox.enable = false;
    };
  };

  home-manager.users.root = _: {
    settings = {
    };
  };

  home-manager = {
    useGlobalPkgs = false;
    useUserPackages = true;
    extraSpecialArgs =
      specialArgs
      // {
        inherit (pkgs) nur;
      }
      // extraArgs;
  };
}
