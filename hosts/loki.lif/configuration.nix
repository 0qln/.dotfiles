{
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
      ];

      settings = {
        enable = true;
        enableWorkSimple = true;
      };

      modules = {
        nixvim = {
          transparency.enable = mkDefault true;
        };
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
