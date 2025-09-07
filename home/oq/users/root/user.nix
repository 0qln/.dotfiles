{config, ...}: {
  sops.secrets."root/hashedPassword" = {
    sopsFile = ./secrets/password.hash.enc;
    owner = "root";
    group = "root";
    mode = "0400";
    format = "binary";
  };

  users.users.root = {
    # this is set explicitly such that things like:
    # userRuntimeDir = "/run/user/${toString sysConfig.users.users.${config.home.username}.uid}";
    # can use the uid... otherwise it's empty for some reason :(
    uid = 0;
    hashedPasswordFile = config.sops.secrets."root/hashedPassword".path;
  };
}
