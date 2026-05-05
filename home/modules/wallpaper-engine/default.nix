{
  config,
  pkgs,
  lib,
  ...
}: let
  monitors = config.vars.monitors.devices;
  cfg = config.modules.wallpaperengine;
in
  with lib; {
    options.modules.wallpaperengine = {
      enable = mkEnableOption "wallpaperengine";
    };

    config = mkIf cfg.enable {
      # docs:
      # https://home-manager-options.extranix.com/?query=linux-wallpaperengine&release=release-25.05
      # https://mynixos.com/home-manager/options/services.linux-wallpaperengine
      # https://github.com/Almamu/linux-wallpaperengine

      # in case i am also as lost as this dud:
      # https://discourse.nixos.org/t/how-is-linux-wallpaperengine-supposed-to-work-on-nixos/37126/6

      services.linux-wallpaperengine = {
        enable = true;
      };

      # Mai 05 17:48:48 lif linux-wallpaperengine[38807]: Duplicate argument --silent. Use /nix/store/zkwh7zy12cc4vcgmhzxlx9nhwm2m0s5n-linux-wallpaperengine-0-unstable-2026-03-01/bin/linux-wallpaperengine --help for>
      systemd.user.services."linux-wallpaperengine".Service.ExecStart = let
        cfg = config.services.linux-wallpaperengine;

        args = wallpaper:
          lib.concatStringsSep " " (
            lib.cli.toGNUCommandLine {} {
              screen-root = wallpaper.monitor;
              inherit (wallpaper) scaling fps;
              silent = wallpaper.audio.silent;
              noautomute = !wallpaper.audio.automute;
              no-audio-processing = !wallpaper.audio.processing;
            }
            ++ wallpaper.extraOptions
          )
          # This has to be the last argument in each group
          + " --bg ${wallpaper.wallpaperId}";

        cmd = wallpaper:
          lib.getExe
          cfg.package
          + " "
          + (lib.optionalString (cfg.assetsPath != null) " --assets-dir ${cfg.assetsPath} ")
          + (lib.optionalString (cfg.clamping != null) "--clamping ${cfg.clamping} ")
          + (args wallpaper)
          + " &";
      in
        mkForce (getExe (pkgs.writeShellScriptBin "commands" (lib.strings.concatLines ((map cmd cfg.wallpapers) ++ ["wait"]))));
    };
  }
