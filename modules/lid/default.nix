{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.lid;
in {
  options.modules.lid = {
    enable = mkEnableOption "lid related stuff";
    dontTurnOffWhenClosed = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "If True: Don't turn off when laptop lid is closed.";
    };
  };

  config = mkIf cfg.enable {
    # Don't turn off when laptop lid is closed.
    services.logind.settings.Login.HandleLidSwitchExternalPower = mkIf cfg.dontTurnOffWhenClosed "ignore";
  };
}
