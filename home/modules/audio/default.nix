{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.audio;
in {
  options.modules.audio = {
    enable = mkEnableOption "audio stuff";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pulseaudio
      pwvucontrol
    ];
  };
}
