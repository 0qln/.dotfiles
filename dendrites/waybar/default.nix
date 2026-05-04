{...}: {
  flake.homeModules.waybar = {
    config,
    lib,
    ...
  }:
    with lib; let
      cfg = config.modules.waybar;
    in {
      options.modules.waybar = {
        enable = mkEnableOption "waybar";
      };

      # docs:
      # waybar in nix:
      #   - https://mynixos.com/home-manager/option/programs.waybar.settings
      # waybar general:
      #   - https://github.com/Alexays/Waybar/wiki/Configuration
      # templating syntax:
      #   - https://docs.gtk.org/Pango/pango_markup.html#pango-markup
      # inspiration
      #   - https://github.com/Alexays/Waybar/blob/master/resources/config.jsonc
      #   - https://github.com/RoastBeefer00/nix-home/blob/main/nix_modules/waybar.nix
      #   - https://gitlab.com/Zaney/zaneyos/-/tree/main/modules/home/waybar?ref_type=heads
      config = mkIf cfg.enable {
        programs.waybar = {
          enable = true;
          style = mkDefault ./waybar.css;
          systemd = {
            enable = true;
          };
        };
      };
    };
}
