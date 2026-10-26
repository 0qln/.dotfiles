{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.deepseek;
in {
  options.modules.deepseek.enable = mkEnableOption "deepseek claude-code wrapper";

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "deepseek" ''
        export ANTHROPIC_AUTH_TOKEN="''${DEEPSEEK_API_KEY}"
        export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
        export ANTHROPIC_MODEL="deepseek-v4-pro[1m]"
        exec claude "$@"
      '')
    ];
  };
}
