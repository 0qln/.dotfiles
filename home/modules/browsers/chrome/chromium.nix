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
          [(import ./extensions/bitwarden.nix)]

          (mkIf cfg.enableWorkSimple [
            (import ./extensions/passbolt.nix)
          ])
        ];
      };
    };
  }
