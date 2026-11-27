let
  theme = "windows-terminal-1";
in
  {
    config,
    flake,
    inputs,
    lib,
    ...
  }:
    with lib; {
      imports = [
        inputs.private.nixosModules."loki.gylfi"

        flake.nixosModules.odoo
        flake.nixosModules.kimai
        flake.nixosModules.checkmk

        ./wslconfig.nix

        (import ../../modules/wireguard/template.nix {
          ip = "10.100.0.4/32";
          serverAddress = config.vars.hosts.lifbrasir.fqdns.primary.dn;
          serverPubKey = builtins.readFile ../lifbrasir/wireguard/0qln/public.key;
          vpnName = "0qln";
        })
      ];

      networking.wireguard.enable = true;

      modules = {
        odoo.enable = true;
        kimai.enable = true;
        checkmk.enable = true;
        docker = {
          enable = true;
          rootless.enable = true;
        };
      };

      home-manager = {
        users.oq = _: {
          imports = [
            flake.homeModules.odoo
            flake.homeModules.kimai
            flake.homeModules.checkmk
            flake.homeModules."themes/${theme}"
          ];

          themes.${theme}.enable = true;

          settings = {
            enable = true;
            enableWorkSimple = true;
          };

          modules = {
            odoo.enable = true;
            kimai.enable = true;
            checkmk.enable = true;
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
