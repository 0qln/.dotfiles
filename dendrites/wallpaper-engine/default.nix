{
  inputs,
  self,
  ...
}: {
  flake.homeModules.linux-wallpaperengine = {
    inputs,
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.modules.wallpaperengine;
  in
    with lib; {
      options.modules.wallpaperengine = {
        enable = mkEnableOption "wallpaperengine";
      };

      options.services.linux-wallpaperengine.wallpapers = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options.screenSpan = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "List of monitors to stretch the wallpaper across (--screen-span).";
          };
          options.fullscreen.pause = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to pause the wallpaper when a fullscreen application is active.";
          };

          config.monitor = lib.mkDefault "";
        });
      };

      config = mkIf cfg.enable {
        # todo: remove when https://github.com/Almamu/linux-wallpaperengine/pull/557 is merged
        nixpkgs.overlays = [
          (_final: prev: {
            linux-wallpaperengine = prev.linux-wallpaperengine.overrideAttrs (_oldAttrs: {
              src = prev.fetchFromGitHub {
                owner = "0qln";
                repo = "linux-wallpaperengine";
                rev = "de69843edeb6e2ba7b2a6c81176e235c85986ff5";
                fetchSubmodules = true;
                hash = "sha256-XibtF+FuYknsCr4AN4TAiN4kxZaczO9h0g/ZK2SPki4=";
              };
            });
          })
        ];

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

          screenSpan = walls:
            walls
            |> strings.intersperse ","
            |> strings.concatStrings;

          args = wallpaper:
            lib.concatStringsSep " " (
              lib.cli.toGNUCommandLine {} {
                inherit (wallpaper) scaling fps;
                silent = wallpaper.audio.silent;
                noautomute = !wallpaper.audio.automute;
                no-audio-processing = !wallpaper.audio.processing;
                no-fullscreen-pause = !wallpaper.fullscreen.pause;
              }
              ++ lib.optionals (wallpaper.monitor != "") ["--screen-root" wallpaper.monitor]
              ++ lib.optionals (wallpaper.screenSpan != []) ["--screen-span" (screenSpan wallpaper.screenSpan)]
              ++ wallpaper.extraOptions
            )
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
    };
}
