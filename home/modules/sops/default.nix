{
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (config.utils) userRuntimeDir;
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  home.packages = with pkgs; [
    sops
  ];

  sops = {
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    # age.keyFile = "/home/oq/age-yubikey-identity-ca0b293d.txt";
    defaultSymlinkPath = "${userRuntimeDir}/secrets";
    defaultSecretsMountPoint = "${userRuntimeDir}/secrets.d";
  };
}
