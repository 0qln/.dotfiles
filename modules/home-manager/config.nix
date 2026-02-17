{
  inputs,
  nur,
  pkgs-citrix,
  pkgs-hot,
  config,
  utilz,
  flake,
  ...
}: let
  inherit (config.vars.home.config) backup;
in {
  extraSpecialArgs = {
    inherit inputs;
    inherit nur;
    inherit pkgs-citrix;
    inherit pkgs-hot;
    inherit utilz;
    inherit flake;
    backupExtension = backup.extension;
    backupCommand = backup.command;
  };
}
