{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.vars;
in {
  config.vars = {
    monitors = with cfg.monitors; {
      arrangement = {
        byName = arrangement.pictograms.${arrangement.byPictogram} devices;
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
      };
    };
  };
}
