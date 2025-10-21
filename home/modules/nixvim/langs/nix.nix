{pkgs, ...}: {
  home.packages = with pkgs; [
    deadnix
    alejandra
    statix
  ];

  programs.nixvim = {
    plugins = {
      nix.enable = true;
    };
  };
}
