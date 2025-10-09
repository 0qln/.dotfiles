{pkgs, ...}: {
  home.packages = with pkgs; [
    vale-ls
  ];

  my-nixvim.wrapLangs = ["md"];
}
