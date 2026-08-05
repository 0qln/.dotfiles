{pkgs, ...}: {
  home.packages = with pkgs; [
    vale-ls
  ];

  modules.nixvim.wrapLangs = ["md"];
}
