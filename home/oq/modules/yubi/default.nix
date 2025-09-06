{ pkgs, ... }:
{
  home.packages = with pkgs; [
    yubikey-manager
    age-plugin-yubikey
  ];

  services.yubikey-agent = {
    enable = true;
  };
}
