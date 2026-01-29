{pkgs, ...}: {
  hardware.opentabletdriver.enable = true;

  environment.systemPackages = with pkgs; [
    usbutils
    xf86_input_wacom
    kdePackages.wacomtablet
  ];

  services.xserver = {
    modules = [pkgs.xf86_input_wacom];

    extraConfig = ''
      Section "InputClass"
          Identifier "ELAN Pen to Wacom"
          MatchUSBID "04f3:42cf" # Your exact device ID from xinput
          MatchDevicePath "/dev/input/event*"
          MatchIsTablet "true"
          Driver "wacom"
      EndSection
    '';
  };
}
