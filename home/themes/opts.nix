{
  lib,
  config,
  ...
}:
with lib; let
  wallpaperType = types.either types.path types.str;
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

    colors = {
      background = config.utils.mkColorOption "background" null;
      background-alt = config.utils.mkColorOption "alternative background" null;
      foreground = config.utils.mkColorOption "foreground" null;
      selected = config.utils.mkColorOption "selected elements" null;
      active = config.utils.mkColorOption "active elements" null;
      urgent = config.utils.mkColorOption "urgent things" null;
    };
  };
}
