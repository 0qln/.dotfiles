{lib, ...}:
with lib; {
  options.vars = let
    domainInfoType = types.submodule {
      options = {
        registrar = mkOption {
          type = types.str;
          description = "The registrar (e.g. cloudflare, duckdns)";
        };
        dn = mkOption {
          type = types.str;
          example = "e.g. example.com";
        };
      };
    };
  in {
    domains = mkOption {
      type = types.attrsOf domainInfoType;
      default = {};
      description = "domain infos";
    };

    system.default = mkOption {
      type = types.str;
      description = "the default system that is assumed in this flake";
    };

    hosts = let
      hostInfoType = types.submodule {
        options = {
          fqdns = mkOption {
            type = types.submodule {
              options = {
                all = mkOption {
                  type = types.listOf types.str;
                  default = [];
                  description = "The fqdns that point to this host";
                };
                primary = mkOption {
                  type = domainInfoType;
                  description = "The primary fqdn";
                };
              };
            };
          };
        };
      };
    in
      mkOption {
        type = types.attrsOf hostInfoType;
        default = {};
        description = "hosts infos";
      };

    home = mkOption {
      type = types.submodule {
        options = {
          config = mkOption {
            type = types.submodule {
              options = {
                backup = mkOption {
                  type = types.submodule {
                    options = {
                      extension = mkOption {
                        type = types.str;
                        description = "Backup file extension";
                      };
                      command = mkOption {
                        type = types.str;
                        description = "Backup file command";
                      };
                    };
                  };
                  default = {};
                  description = "Backup configuration";
                };
              };
            };
            default = {};
            description = "General configuration";
          };
        };
      };
      default = {};
      description = "Home directory configuration";
    };
  };
}
