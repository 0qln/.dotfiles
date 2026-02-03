{
  pkgs,
  inputs,
  nur,
  pkgs-citrix,
  pkgs-hot,
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
    inherit pkgs-hot;
    inherit utilz;
    backupExtension = backup.extension;
    backupCommand = backup.command;
  };
}
