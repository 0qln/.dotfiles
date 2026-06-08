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

        ./mount.nix
      ];

      home-manager = {
        users.oq = _: {
          imports = [
            flake.homeModules."themes/${theme}"
          ];

          themes.${theme}.enable = true;

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
