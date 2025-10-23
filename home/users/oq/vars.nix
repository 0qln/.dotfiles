{
  config,
  lib,
  ...
}:
with lib; {
  config.vars = {
    root = mkDefault config.home.homeDirectory;
    cloud.dir = mkDefault "${config.vars.root}/nextcloud";
    pictures.dir = mkDefault "${config.vars.cloud.dir}/pictures";
    screenshots.dir = mkDefault "${config.vars.pictures.dir}/screenshots";
  };
}
