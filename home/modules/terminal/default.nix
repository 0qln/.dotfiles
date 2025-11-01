{
  lib,
  config,
  ...
}:
with lib; let
  isDir = _file: type: type == "directory";
  emulators = builtins.attrNames (attrsets.filterAttrs isDir (builtins.readDir ./emulators));
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
