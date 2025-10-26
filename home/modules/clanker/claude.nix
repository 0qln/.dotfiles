{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.clanker.claude;
in {
  options.modules.clanker.claude = {
    enable = mkEnableOption "clanker.claude";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      claude-code
    ];
  };
}
