{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.xdg-utils;
in {
  options.modules.xdg-utils = {
    enable = mkEnableOption "xdg-utils";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      xdg-utils
    ];

    # https://wiki.nixos.org/wiki/Default_applications
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        # https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/MIME_types/Common_types
        #TODO: text and code files to kitty+nvim
        #
        # Note: The default apps are specified in the modules
        # that set them (e.g. browser.firefox.zen)
      };
    };
  };
}
