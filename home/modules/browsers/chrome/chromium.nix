{
  config,
  lib,
  ...
}: let
  cfg = config.modules.browser.chrome.chromium;
in
  with lib; {
    options.modules.browser.chrome.chromium = {
      enable = mkEnableOption "chromium";
      enableWorkSimple = mkEnableOption "work simple stuff";
    };
    config = mkIf cfg.enable {
      programs.chromium = {
        enable = true;
        extensions = mkMerge [
          (mkIf cfg.enableWorkSimple [
            (import ./extensions/passbolt.nix)
          ])
        ];
      };
    };
  }
