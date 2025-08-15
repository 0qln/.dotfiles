{
  secrets-env,
  fqdn,
}:
{
  lib,
  pkgs,
  ...
}:
let
  serviceName = "obsidian-livesync";
in
{
  options.services.${serviceName} = {
    enable = lib.mkEnableOption "Obsidian LiveSync";
  };

  imports = [
    (import ./couchdb.nix { inherit serviceName fqdn secrets-env; })
  ];
}
