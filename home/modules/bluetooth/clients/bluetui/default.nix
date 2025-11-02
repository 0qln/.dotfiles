{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.bluetooth;
in {
  config = mkIf (cfg.client == "bluetui") {
    home.packages = with pkgs; [
      bluetui
    ];

    modules.bluetooth.app = "${config.modules.terminal.emulator} bluetui";
  };
}
