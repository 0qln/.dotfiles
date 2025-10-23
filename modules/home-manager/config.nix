{
  inputs,
  nur,
  pkgs-citrix,
  config,
  ...
}: let
  backupExtension = config.vars.home.config.backup.extension;
in {
  extraSpecialArgs = {
    inherit inputs;
    inherit nur;
    inherit pkgs-citrix;
    inherit backupExtension;
  };
  # this is not currently available for standalone home-manager configurations:
  # https://github.com/nix-community/home-manager/pull/7153
  # https://github.com/nix-community/home-manager/issues/5649
  #
  # TODO: uncomment when pr is merged into unstable branch.
  # backupFileExtension = backupExtension;
}
