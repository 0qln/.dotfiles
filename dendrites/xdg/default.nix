{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.xdg = {...}: let
    cfg = config.modules.xdg;
  in {
    options.modules.xdg = {
      enable = mkEnableOption "xdg stuff";
    };

    config = mkIf cfg.enable {
      # https://home-manager-options.extranix.com/?query=xdg.portal.enable&release=release-25.11
      environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"];
    };
  };

  flake.homeModules.xdg = {...}: let
    cfg = config.modules.xdg;
  in {
    options.modules.xdg = {
      enable = mkEnableOption "xdg stuff";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        xdg-utils
      ];

      xdg.portal = {
        enable = mkIf (config.settings.uiEnv == "gui") true;
      };

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
  };
}
