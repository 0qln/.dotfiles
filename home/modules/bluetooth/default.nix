{
  utilz,
  config,
  lib,
  ...
}:
with lib; let
  clients = utilz.mods.collectMods ./clients;
  clientType = types.enum clients;
  cfg = config.modules.bluetooth;
in {
  imports = [
    ./clients/bluetui
  ];

  options.modules.bluetooth = {
    client = mkOption {
      type = types.nullOr clientType;
      default = null;
      description = "The client program to use";
    };
    app = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The command to launch the client";
    };
  };
}
