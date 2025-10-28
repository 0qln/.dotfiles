{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.hypr.bongocat;
in
  with lib; {
    imports = [
      inputs.bongocat.homeModule.default
    ];

    options.modules.hypr.bongocat = {
      enable = config.utils.mkEnableOption "hypr.bongocat" config.modules.hypr.enable;
    };

    config = mkIf cfg.enable {
      programs.wayland-bongocat = let
        pawRatio = 1.0 / 3.0;
        catRatio = 1.0 - pawRatio;
        catHeight = totalHeight * catRatio;
        pawHeight = config.theme.win.layout.margin_out;
        totalHeight = pawHeight / pawRatio;
      in {
        enable = true;
        autostart = true;
        inputDevices = map (i: "/dev/input/event${toString i}") (lib.lists.range 0 8);
        enableAntialiasing = true;
        overlayOpacity = 0;
        overlayHeight = builtins.floor totalHeight;
        overlayPosition = "bottom";
        catHeight = builtins.floor catHeight;
        catAlign = "right";
        catXOffset = 10 + config.theme.win.layout.margin_out;
        catYOffset = 0;
      };
    };
  }
