let
  theme = "windows-terminal-1";
in
  {
    flake,
    inputs,
    lib,
    ...
  }:
    with lib; {
      imports = [
        inputs.private.nixosModules."lif"
        flake.nixosModules.odoo
        flake.nixosModules.kimai

        ./mount.nix
      ];

      modules = {
        odoo.enable = true;
        kimai.enable = true;
        docker = {
          enable = true;
          rootless.enable = true;
        };
      };

      home-manager = {
        users.oq = _: {
          imports = [
            flake.homeModules."themes/${theme}"
            flake.homeModules.odoo
            flake.homeModules.kimai
          ];

          themes.${theme}.enable = true;

          modules = {
            odoo.enable = true;
            kimai.enable = true;
          };

          settings = {
            enable = true;
            enableWorkSimple = true;
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
