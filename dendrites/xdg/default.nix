{
  inputs,
  self,
  ...
}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.xdg = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.modules.xdg;
  in {
    config = mkIf cfg.enable {
      # https://home-manager-options.extranix.com/?query=xdg.portal.enable&release=release-25.11
      environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"];
      xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
      };
    };
  };

  flake.homeModules.xdg = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.modules.xdg;

    # text and code files that should open in the editor (see editor.desktop below)
    textMimeTypes = [
      "text/plain"
      "text/markdown"
      "text/x-log"
      "application/json"
      "application/xml"
      "text/xml"
      "application/yaml"
      "text/yaml"
      "application/x-yaml"
      "text/x-yaml"
      "application/toml"
      "text/x-ini"
      "application/x-shellscript"
      "text/x-shellscript"
      "text/x-python"
      "application/x-python"
      "text/x-nix"
      "application/javascript"
      "text/javascript"
      "text/css"
      "text/x-diff"
      "text/x-patch"
    ];

    editorDesktop = "editor.desktop";
  in {
    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        xdg-utils
      ];

      xdg.enable = true;

      xdg.portal = {
        enable = mkIf (config.settings.uiEnv == "gui") true;
      };

      # open text/code files in the editor (running inside the terminal)
      xdg.desktopEntries.editor = {
        name = "Text Editor";
        genericName = "Text Editor";
        exec = "${config.vars.terminal} ${config.vars.editor} %f";
        terminal = false;
        mimeType = textMimeTypes;
        categories = ["Utility" "TextEditor"];
      };

      # https://wiki.nixos.org/wiki/Default_applications
      xdg.mimeApps = {
        enable = true;
        defaultApplications =
          # https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/MIME_types/Common_types
          # Note: most default apps are specified in the modules that set them
          # (e.g. browser.firefox.zen); text/code files default to the editor here.
          builtins.listToAttrs (
            map (type: {
              name = type;
              value = editorDesktop;
            })
            textMimeTypes
          );
      };
    };
  };
}
