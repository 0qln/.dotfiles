let
  theme = "windows-terminal-1";
in
  {
    flake,
    lib,
    ...
  }:
    with lib; {
      imports = [
        flake.nixosModules.odoo
      ];

      modules = {
        odoo.enable = true;
      };

      home-manager = {
        users.oq = _: {
          imports = [
            flake.homeModules.odoo
            flake.homeModules."themes/${theme}"
          ];

          themes.${theme}.enable = true;

          settings = {
            enable = true;
            enableWorkSimple = true;
          };

          modules = {
            odoo.enable = true;
          };

          private = {
            secrets.ssh = {
              server = true;
              work = true;
              work-devops = true;
            };
          };
        };
      };
    }
