{...}: {
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };

    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      timeoutStyle = "menu";
      extraConfig = ''
        GRUB_CMDLINE_LINUX="video=efifb fbcon=rotate:1"
      '';
    };

    # systemd-boot = {
    #   enable = true;
    #   # extraEntries = {
    #   #   "windows.conf" = ''
    #   #     title Windows Boot Manager
    #   #     efi EFI/Microsoft/Boot/bootmgfw.efi
    #   #   '';
    #   # };
    # };
  };
}
