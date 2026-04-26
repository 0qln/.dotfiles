{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.vars = {
    pkgs,
    config,
    ...
  }: let
    cfg = config.vars;
  in {
    options.vars = {
      domains = let
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
      in
        mkOption {
          type = types.attrsOf domainInfoType;
          default = {};
          description = "domain infos";
        };

      system = mkOption {
        type = types.str;
        description = "the system that is assumed in this flake";
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

    config.vars = {
      system = mkDefault "x86_64-linux";

      home.config.backup = {
        extension = "hm-bac";
        command = "${getExe pkgs.trashy}";
      };

      domains = {
        "0qln.duckdns.org" = {
          dn = "0qln.duckdns.org";
          registrar = "duckdns";
        };
        "07112025.xyz" = {
          dn = "07112025.xyz";
          registrar = "cloudflare";
        };
        "oq.404.mn" = {
          dn = "oq.404.mn";
          registrar = "afraid";
        };
        "nextcloud.myaddr.dev" = {
          dn = "nextcloud.myaddr.dev";
          registrar = "";
        };
      };

      hosts = {
        lifbrasir = {
          fqdns = {
            all = [
              "0qln.duckdns.org"
              "07112025.xyz"
            ];
            primary = cfg.domains."07112025.xyz";
          };
        };
      };
    };
  };
}
