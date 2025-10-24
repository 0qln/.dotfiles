{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.browser;
in {
  imports = [
    ./firefox
    ./chrome
  ];

  options.modules.browser = {
    _xdgMimeTypes = mkOption {
      type = types.listOf types.str;
      internal = true;
      default = [
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/chrome"
        "text/html"
        "application/x-extension-htm"
        "application/x-extension-html"
        "application/x-extension-shtml"
        "application/xhtml+xml"
        "application/x-extension-xhtml"
        "application/x-extension-xht"
      ];
    };
    _xdgDefault = mkOption {
      type = types.str;
      internal = true;
    };
  };

  config = {
    xdg.mimeApps.defaultApplications = builtins.listToAttrs (
      map (type: {
        name = type;
        value = cfg._xdgDefault;
      })
      cfg._xdgMimeTypes
    );
  };
}
