args@{
  config,
  pkgs,
  inputs,
  ...
}:
let
  inherit (args.utils args) userRuntimeDir;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

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
