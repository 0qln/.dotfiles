{lib, ...}: let
  config = import ./default.nix {
    inherit lib;
    inherit (config) config;
  };
in
  config.config.utils
