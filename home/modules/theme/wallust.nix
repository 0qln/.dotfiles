{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.wallust;
in {
  options.modules.wallust = {
    enable = mkEnableOption "wallust";
    wallpaper = mkOption {
      type = types.path;
      description = "The wallpaper to use when generating the themes. Defaults to the center wallpaper currently set in config.themes.wallpapers.";
      default = let
        mons = config.vars.monitors;
        pict = mons.arrangement.byPictogram;
        wals = config.theme.wallpapers.arrangements.${pict};
        main = wals.center;
      in
        toString main;
    };
    settings = mkOption {
      type = types.attrs;
      default = {
        # wallust v3.4
        #
        # You can copy this file to ~/.config/wallust/wallust.toml (keep in mind is a sample config)

        # SIMPLE TUTORIAL, or `man wallust.5`:
        # https://explosion-mental.codeberg.page/wallust/
        #
        # If comming from v2: https://explosion-mental.codeberg.page/wallust/v3.html#wallusttoml

        # Global section - values below can be overwritten by command line flags

        # How the image is parse, in order to get the colors:
        # full - resized - wal - thumb -  fastresize - kmeans
        # backend = "fastresize";

        # What color space to use to produce and select the most prominent colors:
        # lab - labmixed - lch - lchmixed
        # color_space = "lch";

        # Use the most prominent colors in a way that makes sense, a scheme color palette:
        # dark - dark16 - darkcomp - darkcomp16
        # light - light16 - lightcomp - lightcomp16
        # harddark - harddark16 - harddarkcomp - harddarkcomp16
        # softdark - softdark16 - softdarkcomp - softdarkcomp16
        # softlight - softlight16 - softlightcomp - softlightcomp16
        # palette = "dark";

        # Ensures a "readable contrast" (OPTIONAL, disabled by default)
        # Should only be enabled when you notice an unreadable contrast frequently happening
        # with your images. The reference color for the contrast is the background color.
        # check_contrast = true;

        # Color saturation, between [1% and 100%] (OPTIONAL, disabled by default)
        # usually something higher than 50 increases the saturation and below
        # decreases it (on a scheme with strong and vivid colors)
        # saturation = 35;

        # Alpha value for templating, by default 100 (no other use whatsoever)
        # alpha = 100;

        templates = {
          # NOTE: prefer '' over "" for paths, avoids escaping.
          # template: A RELATIVE path that points to `~/.config/wallust/template` (depends on platform)
          # target: ABSOLUTE path in which to place a file with generated templated values.
          # ¡ If either one is a directory, then both SHOULD be one. !
          # zathura = {
          #   template = "zathura";
          #   target = "~/.config/zathura/zathurarc";
          # };
          waybar = {
            template = "waybar.css";
            target = "~/.config/waybar/colors.css";
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    programs.wallust = {
      enable = true;
      inherit (cfg) settings;
    };

    home.file.".config/wallust/templates".source = ./templates;

    systemd.user.services."wallust-run" = {
      Unit = {
        Description = "Generate color pallets using wallust";
        After = ["graphical-session.target"];
      };

      Service = {
        ExecStart = "${pkgs.writeShellScript "wallust-run" ''
          wallust -s run ${builtins.toString cfg.wallpaper}
        ''}";
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
