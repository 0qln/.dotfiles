{ ... }:
{
  # usage: bluetoothctl
  # docs: https://nixos.wiki/wiki/Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {

    };
  };
}
