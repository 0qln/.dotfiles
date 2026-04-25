{inputs, ...}: {
  flake.nixosModules.nix = {
    config,
    lib,
    ...
  }:
    with lib; let
      cfg = config.modules.obsidian-digitalgarden;
    in {
      # todo: implement a service for selfhosting obsidian-digitalgarden (https://github.com/oleeskild/digitalgarden)

      options.modules.obsidian-digitalgarden = {
      };

      config = {
      };
    };
}
