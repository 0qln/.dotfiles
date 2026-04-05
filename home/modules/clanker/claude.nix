{
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
    programs.claude-code = {
      enable = true;
      settings = {
        includeCoAuthoredBy = false;
      };
    };
  };
}
