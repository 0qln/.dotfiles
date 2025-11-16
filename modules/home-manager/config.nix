{
  pkgs,
  inputs,
  nur,
  pkgs-citrix,
  pkgs-stable,
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
    inherit pkgs-stable;
    inherit backupExtension;
    inherit utilz;
  };

  backupFileExtension = backupExtension;

  backupCommand = pkgs.lib.getExe pkgs.trashy;
}
