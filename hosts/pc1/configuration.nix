{ ... }:
{
  imports = [
    ./bootloader.nix
    ./mount.nix
    ./bluetooth.nix
    ./glorious-model-o.nix
    ../../users/oq
    ../../modules/hypr
  ];

  #TODO: move this in the home config, as soon as the home manager options have the presets...
  programs.starship = {
    enable = true;
    presets = [
      "nerd-font-symbols"
      "catppuccin-powerline"
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };
}
