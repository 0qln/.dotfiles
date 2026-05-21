{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.clanker.github-copilot;
in {
  options.modules.clanker.github-copilot = {
    enable = mkEnableOption "clanker.github-copilot";
  };

  config = mkIf cfg.enable {
    # https://home-manager-options.extranix.com/?query=github-copilot-cli&release=master
    programs.github-copilot-cli = {
      enable = true;
      enableMcpIntegration = true;
      settings = {
        includeCoAuthoredBy = false;
      };
    };
  };
}
