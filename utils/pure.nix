{lib, ...}:
with import ./ez.nix;
  import-module ./module.nix {inherit lib;}
