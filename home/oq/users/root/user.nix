{...}: {
  users.users.root = {
    # this is set explicitly such that things like:
    # userRuntimeDir = "/run/user/${toString sysConfig.users.users.${config.home.username}.uid}";
    # can use the uid... otherwise it's empty for some reason :(
    uid = 0;
  };
}
