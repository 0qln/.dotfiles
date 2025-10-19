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
    users.oq = _: {
      imports = [../../hosts/lif/variables.nix];
      settings = {
        uiEnv = "gui";
        # theme.name = "wlop-1_chinese-festival";
      };
    };

    users.root = _: {
      settings = {
        uiEnv = "gui";
      };
    };

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
