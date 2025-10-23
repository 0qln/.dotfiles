{lib, ...}: {
  options.vars = {
    home = lib.mkOption {
      type = lib.types.submodule {
        options = {
          config = lib.mkOption {
            type = lib.types.submodule {
              options = {
                backup = lib.mkOption {
                  type = lib.types.submodule {
                    options = {
                      extension = lib.mkOption {
                        type = lib.types.str;
                        description = "Backup file extension";
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
