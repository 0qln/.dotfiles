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
        banner = "never";
        includeCoAuthoredBy = false;
        trusted_folders = [
          config.vars.repos.dir
          config.vars.flake.dir
        ];
      };
      skills = {};
      mcpServers = {
        playwright = {
          type = "local";
          command = "npx";
          args = ["@playwright/mcp@latest"];
          tools = ["*"];
        };
      };
      lspServers = {};
      context = ''

      '';
    };
  };
}
