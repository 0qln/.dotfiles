args@{ config, pkgs, ... }:
let
  inherit (args.utils args) userRuntimeDir;
in
  {
  home.packages = with pkgs; [
    sops
  ];

  sops = {
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    defaultSymlinkPath = "${userRuntimeDir}/secrets";
    defaultSecretsMountPoint = "${userRuntimeDir}/secrets.d";
  };
}
