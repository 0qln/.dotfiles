{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.hyprland-opts = {...}: {
    options.modules.hyprland = {
      enable = mkEnableOption "hyprland";
    };
  };

  flake.homeModules.hyprland-opts = {...}: {
    options.modules.hyprland = {
      enable = mkEnableOption "hyprland";
    };

    # todo: this or another file?
    options.modules.hyprland.input = {
      submaps = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            key = mkOption {type = types.str;};
            binds = mkOption {
              type = types.listOf (types.either types.str (types.submodule {
                options = {
                  flags = mkOption {
                    type = types.str;
                    default = "";
                  };
                  keys = mkOption {type = types.str;};
                  dispatch = mkOption {type = types.str;};
                  reset = mkOption {
                    type = types.bool;
                    default = false;
                  };
                };
              }));
            };
          };
        });
      };
      mainMod = mkOption {
        type = types.str;
        default = "SUPER";
      };
    };
  };
}
