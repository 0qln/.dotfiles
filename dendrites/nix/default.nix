{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.nix = {config, ...}: let
    cfg = config.modules.nix;
  in {
    options.modules.nix = {
      caches = mkOption {
        type = types.attrs;
        default = {};
        example = {
          "hyprland.cachix.org" = "a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
        };
      };
    };

    config = {
      nixpkgs.config.allowUnfree = mkDefault true;

      nix.settings = mkMerge (
        (let
          mkSubstituter = fqdn: key: {
            substituters = ["https://${fqdn}"];
            trusted-substituters = ["https://${fqdn}"];
            trusted-public-keys = ["${fqdn}-1:${key}"];
          };
        in
          attrsets.mapAttrsToList mkSubstituter cfg.caches)
        ++ [
          {
            trusted-users = [ "root" "@wheel" ];
          }
          {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
          }
          {
            experimental-features = [
              "pipe-operators"
            ];
          }
        ]
      );
    };
  };

  flake.homeModules.nix = {pkgs, ...}: {
    imports = [
      inputs.nix-index-database.homeModules.default
    ];

    config = {
      nixpkgs.config.allowUnfree = mkDefault true;

      programs.nix-index-database.comma.enable = true;

      home.packages = with pkgs; [
        nurl
        nix-init
      ];
    };
  };
}
