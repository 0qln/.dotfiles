{pkgs, ...}: {
  home.file.".local/share/fonts/CartographCF" = {
    source = "${import ./derivation.nix {inherit pkgs;}}";
    recursive = true;
  };
}
