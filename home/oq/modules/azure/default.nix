{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # this package is useless, just use the install script from the repo:
    # https://github.com/microsoft/artifacts-credprovider
    # azure-artifacts-credprovider
  ];
}
