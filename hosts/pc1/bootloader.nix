{ ... }:
{
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      extraEntries = {
        "windows.conf" = ''
          title Windows
          efi /mnt/windows-efi/EFI/Microsoft/Boot/bootmgfw.efi
        '';
      };
    };
    timeout = 5;
  };
}
