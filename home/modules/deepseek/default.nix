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
        case "''${1:-}" in
          pro)   model="deepseek-v4-pro[1m]";   shift ;;
          flash) model="deepseek-v4-flash[1m]"; shift ;;
          *)     model="deepseek-v4-pro[1m]" ;;
        esac

        export ANTHROPIC_AUTH_TOKEN="''${DEEPSEEK_API_KEY}"
        export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
        export ANTHROPIC_MODEL="$model"

        # Make both models reachable via /model (Sonnet/Opus = pro, Haiku =
        # flash) and keep background tasks on flash, so nothing ever sends a
        # Claude model id that does not exist on the DeepSeek endpoint.
        export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]"
        export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro[1m]"
        export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash[1m]"
        export ANTHROPIC_SMALL_FAST_MODEL="deepseek-v4-flash[1m]"

        exec claude "$@"
      '')
    ];
  };
}
