{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.nix;
in {
  options.modules.nix = {
    enable = mkEnableOption "nix related stuff";
    caches = mkOption {
      type = types.attrs;
      default = {};
      example = {
        "hyprland.cachix.org" = "a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
      };
    };
    flakes.enable = mkEnableOption "flakes stuff";
  };

  config = mkIf cfg.enable {
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
        (mkIf cfg.flakes.enable {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        })
        {
          experimental-features = [
            "pipe-operators"
          ];
        }
      ]
    );
  };
}
