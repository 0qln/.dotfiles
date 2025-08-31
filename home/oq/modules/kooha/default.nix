{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kooha # video recording
  ];
}
