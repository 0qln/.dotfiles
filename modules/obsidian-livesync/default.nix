{lib, ...}:
with lib; {
  options.modules.obsidian-livesync = {
    enable = mkEnableOption "Obsidian LiveSync";
    couchdb = {
      secretsEnvFile = mkOption {
        type = types.path;
      };
      fqdn = mkOption {
        type = types.str;
      };
      configFile = mkOption {
        type = types.path;
      };
    };
  };

  imports = [
    ./couchdb.nix
  ];
}
