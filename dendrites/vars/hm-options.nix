{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vars;
in {
  options.vars = let
    programType = types.strMatching "[a-zA-Z0-9_-]+";
  in {
    user = lib.mkOption {
      type = lib.types.submodule {
        options = {
          uid = lib.mkOption {
            type = lib.types.int;
            description = "User id";
          };
        };
      };
      default = {};
      description = "System User configuration";
    };

    root = lib.mkOption {
      type = lib.types.str;
      description = "Home directory path";
    };

    flake = lib.mkOption {
      type = lib.types.submodule {
        options = {
          dir = lib.mkOption {
            type = lib.types.str;
            description = "Dotfiles flake location";
          };
        };
      };
      default = {};
      description = "Dotfiles flake vars";
    };

    cloud = lib.mkOption {
      type = lib.types.submodule {
        options = {
          dir = lib.mkOption {
            type = lib.types.str;
            description = "Nextcloud directory path";
          };
        };
      };
      default = {};
      description = "Nextcloud configuration";
    };

    repos = lib.mkOption {
      type = lib.types.submodule {
        options = {
          dir = lib.mkOption {
            type = lib.types.str;
            description = "Projects directory path";
          };
        };
      };
      default = {};
      description = "Projects configuration";
    };

    pictures = lib.mkOption {
      type = lib.types.submodule {
        options = {
          dir = lib.mkOption {
            type = lib.types.str;
            description = "Pictures directory path";
          };
        };
      };
      default = {};
      description = "Pictures configuration";
    };

    screenshots = lib.mkOption {
      type = lib.types.submodule {
        options = {
          dir = lib.mkOption {
            type = lib.types.str;
            description = "Screenshots directory path";
          };
        };
      };
      default = {};
      description = "Screenshots configuration";
    };

    editor = mkOption {
      type = programType;
      default = "nvim";
      description = "Default text editor";
      example = "nvim";
    };

    fileexplorer = mkOption {
      type = programType;
      default = "lf";
      description = "Default file explorer";
      example = "lf";
    };

    sysfetcher = mkOption {
      type = programType;
      default = "fastfetch";
      description = "System information fetcher";
      example = "fastfetch";
    };

    terminal = mkOption {
      type = programType;
      default = "kitty";
      description = "Default terminal emulator";
      example = "kitty";
    };

    music-player = mkOption {
      type = programType;
      default = "${getExe pkgs.pear-desktop}";
      description = "Default music player";
      example = "spotify";
    };

    monitors = let
      deviceType = types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Monitor output name (e.g., HDMI-A-1, DP-2)";
          };
          dim = mkOption {
            type = dimensionType;
            # have to redefine the defaults here bc idk why it be broken otherwise.
            default = {
              w = dimensionTypeDef.options.w.default;
              h = dimensionTypeDef.options.h.default;
              s = dimensionTypeDef.options.s.default;
            };
            description = "Monitor dimensions";
          };
          hz = mkOption {
            type = types.int;
            default = 60;
            description = "Monitor refresh rate in Hz";
          };
          workspaces = mkOption {
            type = types.listOf types.int;
            default = [];
            description = "The workspaces accociated with this monitor";
          };
        };
      };

      dimensionTypeDef = {
        options = {
          w = mkOption {
            type = types.int;
            default = 1920;
            description = "Monitor width in pixels";
          };
          h = mkOption {
            type = types.int;
            default = 1080;
            description = "Monitor height in pixels";
          };
          s = mkOption {
            type = types.float;
            default = 1.0;
            description = "Monitor scaling. 1 is unscaled.";
          };
        };
      };

      dimensionType = types.submodule dimensionTypeDef;

      positionType = types.submodule {
        options = {
          x = mkOption {
            type = types.int;
            default = 0;
            description = "X left offset of the monitor";
          };
          y = mkOption {
            type = types.int;
            default = 0;
            description = "Y top offset of the monitor";
          };
          r = mkOption {
            type = types.enum [
              0 # none
              1 # left
              2 # upside down
              3 # right
            ];
            default = 0;
            description = "Rotation of the monitor";
          };
        };
      };
    in {
      devices = mkOption {
        type = types.attrsOf deviceType;
        default = {};
        description = "Monitor device definitions";
      };

      arrangement = mkOption {
        type = types.submodule {
          options = {
            pictograms = mkOption {
              type = types.attrs;
              default = {};
              description = "Possible arrangement pictograms";
            };

            byPictogram = mkOption {
              type = types.enum (builtins.attrNames cfg.monitors.arrangement.pictograms);
              default = "-";
              description = "Set the arrangement pattern by specifying a pictogram";
            };

            byName = mkOption {
              type = types.attrsOf positionType;
              description = "Monitor arrangement by name";
            };
          };
        };
        description = "Monitor arrangement configuration";
      };
    };
  };
}
