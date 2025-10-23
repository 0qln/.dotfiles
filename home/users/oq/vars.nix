{
  config,
  lib,
  ...
}:
with lib; {
  config.vars = let
    root =
      if builtins.hasAttr "home" config
      then config.home.homeDirectory
      else "/home/oq/";
  in {
    root = mkDefault root;
    cloud.dir = mkDefault "${config.vars.root}/nextcloud";
    pictures.dir = mkDefault "${config.vars.cloud.dir}/pictures";
    screenshots.dir = mkDefault "${config.vars.pictures.dir}/screenshots";
  };
}
