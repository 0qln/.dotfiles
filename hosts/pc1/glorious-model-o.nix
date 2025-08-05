{ pkgs, ... }:
let
  gloriousctl = pkgs.stdenv.mkDerivation {
    pname = "gloriousctl";
    version = "1.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "enkore";
      repo = "gloriousctl";
      rev = "c968050e951f6c4d12c07f3b6551c072f7c72a0a";
      sha256 = "sha256-69yRab0Mx6elwkvxpmAWeaQEDTl5jBObUnoPlh0Jba0=";
    };

    buildInputs = [ pkgs.hidapi ];

    # Patch the source to add new device IDs
    postPatch = ''
      sed -i 's|{ .vid = 0x258a, .pid = 0x36, .name =  "Glorious Model O/O-" },|&\n    { .vid = 0x258a, .pid = 0x2022, .name = "Glorious Model O Wireless (2022)" },\n    { .vid = 0x258a, .pid = 0x2011, .name = "Glorious Model O Wireless (2011)" },|' gloriousctl.c
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp gloriousctl $out/bin
      runHook postInstall
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    # if you try to change your mouse settings with this you will likely brick your mouse :)
    # gloriousctl
    libratbag
    piper
    usbutils

    #TODO: try out https://github.com/dkbednarczyk/mxw
  ];

  services.ratbagd.enable = true;

  services.udev.extraRules = ''
    # Glorious mice
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="258a", ATTRS{idProduct}=="0027", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="258a", ATTRS{idProduct}=="0033", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="258a", ATTRS{idProduct}=="0036", MODE="0666"
  '';

  # systemd.services.ratbagd.enable = true;
}
