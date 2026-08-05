{pkgs, ...}: {
  home.packages = with pkgs; [
    luaPackages.luacheck
  ];
}
