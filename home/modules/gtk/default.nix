{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  options.modules.gtk = {
    enable = mkEnableOption "GTK theming";
  };

  config = mkIf config.modules.gtk.enable {
    gtk = {
      enable = true;
      colorScheme = mkIf (config.theme.mode == "dark") "dark";
      theme = mkIf (config.theme.mode == "dark") {
        package = pkgs.gnome-themes-extra;
        name = "Adwaita-dark";
      };
    };

    dconf = {
      settings = {
        "org/gnome/desktop/interface" = mkIf (config.theme.mode == "dark") {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita-dark";
        };
      };
    };
  };
}
