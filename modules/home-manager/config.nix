{
  pkgs,
  inputs,
  nur,
  pkgs-citrix,
  config,
  utilz,
  ...
}: let
  inherit (config.vars.home.config) backup;
in {
  extraSpecialArgs = {
    inherit inputs;
    inherit nur;
    inherit pkgs-citrix;
    inherit utilz;
    backupExtension = backup.extension;
    backupCommand = backup.command;
  };
}
