{
  lib,
  config,
  ...
}:
with lib;
with config.utils; let
  wallpaperType = types.either types.path types.str;
  cfg = config.theme;
in {
  options.theme = {
    wallpapers = {
      arrangements = mkOption {
        type = types.attrs;
        default = {};
        description = "Monitor arrangement to wallpaper mappings";
        example = {
          "|-|" = {
            left = "vert1";
            center = "horz1";
            right = "vert2";
          };
          "-" = {
            center = "horz1";
          };
        };
      };

      images = mkOption {
        type = types.attrsOf wallpaperType;
        default = {};
        description = "Named wallpaper images";
        example = {
          vert1 = "/path/to/vertical1.jpg";
          horz1 = "/path/to/horizontal1.jpg";
        };
      };
    };

    fonts = {
      monospace = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "default font for monospace stuff";
      };
      reading = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "default font for reading stuff";
      };
    };

    win = {
      border = {
        active = mkColorOption "active window's border" null;
        inactive = mkColorOption "inactive window's border" null;
        size = mkOption {
          type = types.ints.unsigned;
          default = 0;
          description = "window's border size";
        };
      };
      layout = {
        gaps_in = mkOption {
          type = types.ints.unsigned;
          default = 10;
          description = "gaps in between windows";
        };
        gaps_out = mkOption {
          type = types.ints.unsigned;
          default = 20;
          description = "around all windows";
        };
        margin_out = mkOption {
          type = types.ints.unsigned;
          default = cfg.win.layout.gaps_out + cfg.win.border.size;
        };
      };
      shadow = {
        active = mkColorOption "active window's shadow" null;
        inactive = mkColorOption "inactive window's shadow" null;
        range = mkOption {
          type = types.ints.unsigned;
          default = 5;
          description = "shadow size/radius in pixels";
        };
        render_power = mkOption {
          type = types.ints.unsigned;
          default = 3;
          description = "";
        };
      };
      opacity = {
        active = mkOption {
          type = types.float;
          default = 1.0;
          description = "opacity level for active windows (0.0-1.0)";
        };
        inactive = mkOption {
          type = types.float;
          default = 1.0;
          description = "opacity level for inactive windows (0.0-1.0)";
        };
        background = mkOption {
          type = types.float;
          default = 1.0;
          description = "background opacity level for apps (0.0-1.0)";
        };
      };
      corners = {
        rounding = mkOption {
          type = types.ints.unsigned;
          default = 10;
          description = "corner radius in pixels";
        };
        rounding_power = mkOption {
          type = types.ints.unsigned;
          default = 2;
          description = "corner smoothing/anti-aliasing quality";
        };
      };
      blur = {
        size = mkOption {
          type = types.ints.unsigned;
          default = 10;
          description = "blur radius/strength";
        };
        passes = mkOption {
          type = types.ints.unsigned;
          default = 2;
          description = "number of blur iterations";
        };
        vibrancy = mkOption {
          type = types.float;
          default = 0.5;
          description = "blur intensity/vibrancy (0.0-1.0)";
        };
      };
    };

    term = {
      padding = mkOption {
        type = types.ints.unsigned;
        default = 0;
        description = "terminal padding";
      };

      cursor = mkColorOption "terminal cursor" null;
      background = mkColorOption "terminal background" null;
      foreground = mkColorOption "terminal foreground" null;
      selection_background = mkColorOption "terminal selection_background" null;
      selection_foreground = mkColorOption "terminal selection_foreground" null;
      color0 = mkColorOption "terminal color0" null;
      color8 = mkColorOption "terminal color8" null;
      color1 = mkColorOption "terminal color1" null;
      color9 = mkColorOption "terminal color9" null;
      color2 = mkColorOption "terminal color2" null;
      color10 = mkColorOption "terminal color10" null;
      color3 = mkColorOption "terminal color3" null;
      color11 = mkColorOption "terminal color11" null;
      color4 = mkColorOption "terminal color4" null;
      color12 = mkColorOption "terminal color12" null;
      color5 = mkColorOption "terminal color5" null;
      color13 = mkColorOption "terminal color13" null;
      color6 = mkColorOption "terminal color6" null;
      color14 = mkColorOption "terminal color14" null;
      color7 = mkColorOption "terminal color7" null;
      color15 = mkColorOption "terminal color15" null;
    };

    launcher = {
      background = mkColorOption "background" null;
      border = mkColorOption "border" null;
      background-alt = mkColorOption "alternative background" null;
      foreground = mkColorOption "foreground" null;
      foreground-selected = mkColorOption "foreground-selected" null;
      selected = mkColorOption "selected elements" null;
      active = mkColorOption "active elements" null;
      urgent = mkColorOption "urgent things" null;
    };
  };
}
