{
  inputs,
  nur,
  pkgs-citrix,
  backupExtension,
  ...
}: {
  useGlobalPkgs = false;
  useUserPackages = true;
  extraSpecialArgs = {
    inherit inputs;
    inherit nur;
    inherit pkgs-citrix;
    inherit backupExtension;
  };
  backupFileExtension = backupExtension;
}
