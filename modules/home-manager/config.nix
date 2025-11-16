{
  pkgs,
  inputs,
  nur,
  pkgs-citrix,
  config,
  utilz,
  ...
}: let
  backupExtension = config.vars.home.config.backup.extension;
in {
  extraSpecialArgs = {
    inherit inputs;
    inherit nur;
    inherit pkgs-citrix;
    inherit backupExtension;
    inherit utilz;
  };

  backupFileExtension = backupExtension;

  backupCommand = pkgs.lib.getExe pkgs.trashy;
}
