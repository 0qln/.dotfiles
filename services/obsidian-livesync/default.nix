{
  config,
  lib,
  pkgs,
  ...
}:
let
  serviceName = "obsidian-livesync";
in
secrets-env: {
  options.services.${serviceName} = {
    enable = lib.mkEnableOption "Obsidian LiveSync";
  };

  imports = [
    (pkgs.callPackage ./couchdb.nix { inherit serviceName secrets-env; })
  ];
}
