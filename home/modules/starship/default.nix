{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.starship;
in {
  options.modules.starship = {
    enable = mkEnableOption "starship";
    presets = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "presets to use (see https://starship.rs/presets/ for a list of valid options)";
    };
    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "starship settings";
    };
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = lib.mkMerge ([
          # user settings
          cfg.settings

          # tmux integration
          (mkIf (!config.modules.tmux.statusline.enable) {
            custom.tmux = {
              description = ''Indicator that shows up if currently in a tmux session'';
              command = ''echo '■' '';
              when = ''[[ -n $TMUX ]] && exit 0 '';
            };
          })
        ]
        # presets
        ++ map (preset: (builtins.fromTOML
          (
            builtins.readFile "${pkgs.starship}/share/starship/presets/${preset}.toml"
          )))
        cfg.presets);
    };
  };
}
