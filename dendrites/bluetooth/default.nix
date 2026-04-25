{inputs, ...}: {
  flake.nixosModules.bluetooth = {
    config,
    lib,
    ...
  }:
    with lib; let
      cfg = config.modules.bluetooth;
    in {
      options.modules.bluetooth = {
        enable = mkEnableOption "bluetooth";
      };

      config = mkIf cfg.enable {
        # usage: bluetoothctl
        # docs: https://nixos.wiki/wiki/Bluetooth
        hardware.bluetooth = {
          enable = true;
          powerOnBoot = true;
          settings = {
          };
        };
      };
    };

  flake.homeModules.bluetooth = {
    config,
    pkgs,
    lib,
    ...
  }:
    with lib; let
      clientType = types.enum ["bluetui"];
      cfg = config.modules.bluetooth;
    in {
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

      config = mkMerge [
        (mkIf (cfg.client == "bluetui") {
          home.packages = with pkgs; [bluetui];
          modules.bluetooth.app = "${config.modules.terminal.emulator} bluetui";
        })
      ];
    };
}
