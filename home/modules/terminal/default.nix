{
  lib,
  config,
  utilz,
  ...
}:
with lib; let
  emulators = utilz.mods.collectMods ./emulators;
  emulatorType = types.enum emulators;
in {
  imports = [
    ./emulators/kitty
  ];

  options.modules.terminal = {
    emulator = mkOption {
      type = emulatorType;
      default = "tty";
      description = "The terminal emulator program";
    };
    font = mkOption {
      type = types.nullOr types.str;
      default = config.theme.fonts.monospace;
      example = "VictorMono Nerd Font";
      description = "The font";
    };
    backgroundOpacity = mkOption {
      type = types.float;
      default = 0.8;
      description = "Background opacity";
    };
  };
}
