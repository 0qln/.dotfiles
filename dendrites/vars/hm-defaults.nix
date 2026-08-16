{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.vars;
in {
  config.vars = {
    monitors = with cfg.monitors; let
      monList = builtins.attrValues devices;
      physicalWidth = r: w: h:
        if (r == 1 || r == 3)
        then h
        else w;

      physicalHeight = r: w: h:
        if (r == 1 || r == 3)
        then w
        else h;
    in {
      arrangement = {
        byName = mkMerge [
          (arrangement.pictograms.${arrangement.byPictogram} devices)
          (builtins.listToAttrs (map (device: {
              inherit (device) name;
              value = let
                inherit (device.dim) w h;
                inherit (arrangement.byName.${device.name}) r;
              in {
                physicalW = mkDefault (physicalWidth r w h);
                physicalH = mkDefault (physicalHeight r w h);
              };
            })
            monList))
        ];
        pictograms = {
          "|-|" = devices:
            with devices; {
              ${center.name} = {
                x = mkDefault 0;
                y = mkDefault (left.dim.w / 2 - center.dim.h / 2);
                r = mkDefault 0;
              };
              ${left.name} = {
                x = mkDefault (-left.dim.h);
                y = mkDefault 0;
                r = mkDefault 3;
              };
              ${right.name} = {
                x = mkDefault center.dim.w;
                y = mkDefault 0;
                r = mkDefault 1;
              };
            };

          " -|" = devices:
            with devices; {
              ${center.name} = {
                x = mkDefault 0;
                y = mkDefault (right.dim.w / 2 - center.dim.h / 2);
                r = mkDefault 0;
              };
              ${right.name} = {
                x = mkDefault center.dim.w;
                y = mkDefault 0;
                r = mkDefault 1;
              };
            };

          "-" = d:
            with d; {
              ${center.name} = {
                x = mkDefault 0;
                y = mkDefault 0;
                r = mkDefault 0;
              };
            };
        };

        totalW = arrangement.maxX - arrangement.minX;
        totalH = arrangement.maxY - arrangement.minY;

        minX =
          builtins.foldl' (
            acc: m: let
              x = arrangement.byName.${m.name}.x;
            in
              if x < acc
              then x
              else acc
          )
          999999
          monList;

        maxX =
          builtins.foldl' (
            acc: m: let
              x = arrangement.byName.${m.name}.x;
              w = arrangement.byName.${m.name}.physicalW;
              edgeX = x + w;
            in
              if edgeX > acc
              then edgeX
              else acc
          ) (-999999)
          monList;

        minY =
          builtins.foldl' (
            acc: m: let
              y = arrangement.byName.${m.name}.y;
            in
              if y < acc
              then y
              else acc
          )
          999999
          monList;

        maxY =
          builtins.foldl' (
            acc: m: let
              y = arrangement.byName.${m.name}.y;
              h = arrangement.byName.${m.name}.physicalH;
              edgeY = y + h;
            in
              if edgeY > acc
              then edgeY
              else acc
          ) (-999999)
          monList;
      };
    };
  };
}
