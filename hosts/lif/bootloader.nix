{ ... }:
{
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      # efiSysMountPoint = "/boot";
    };

    systemd-boot = {
      enable = true;
      # extraEntries = {
      #   "windows.conf" = ''
      #     title Windows Boot Manager
      #     efi EFI/Microsoft/Boot/bootmgfw.efi
      #   '';
      # };
    };

    timeout = 5;
  };
}
