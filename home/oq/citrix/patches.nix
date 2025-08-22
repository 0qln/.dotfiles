{ pkgs, ... }:
{
  nixpkgs.config.permittedInsecurePackages = [
    "libxml2-2.13.8"
    "libsoup-2.74.3"
  ];
}
