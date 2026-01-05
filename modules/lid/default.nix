{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.lid;
in {
  options.modules.lid = {
    disable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    # Don't turn off when laptop lid is closed.
    services.logind.settings.Login.HandleLidSwitchExternalPower = mkIf cfg.disable "ignore";
  };
}
