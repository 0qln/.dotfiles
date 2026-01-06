{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.input;
in {
  options.modules.input = {
    mouse = {
      speed = mkOption {
        type = types.float;
        default = 0.0;
        description = "Cursor speed (possible values are in range -1 to 1)";
      };
      accel = mkOption {
        type = types.bool;
        default = false;
        description = "Enable mouse accelleration";
      };
    };
  };
}
