{pkgs, ...}: let
  # theme = import ../../variables/colors/presets/0815-blue;
in {
  imports = [
    (import ../../modules/home-manager {
      extraArgs = {
      };
    })
  ];

  # config.variables = import ../../variables/colors/presets/0815-blue.nix;
}
