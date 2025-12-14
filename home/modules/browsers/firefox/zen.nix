args @ {
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.browser.firefox.zen;
in
  with lib; {
    imports = with inputs; [
      zen-browser.homeModules.twilight
    ];

    options.modules.browser.firefox.zen = {
      enable = mkEnableOption "zen";
      setDefault = mkEnableOption "set default browser";
      profiles = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "a list of strings of profiles that are defined in ./profiles";
      };
    };

    config = mkIf cfg.enable {
      modules.browser._xdgDefault = mkIf cfg.setDefault (mkDefault "zen-twilight.desktop");

      programs.zen-browser = {
        enable = true;

        # any other options under `programs.firefox` are also supported here.

        profiles = import ./profiles/_import.nix (args // cfg);
      };
    };
  }
