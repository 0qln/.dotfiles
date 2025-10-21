{lib, ...}:
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
  };
}
