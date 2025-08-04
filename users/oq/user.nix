{ ... }:
{
  users.users.oq = {
    isNormalUser = true;
    # this is set explicitly such that things like:
    # userRuntimeDir = "/run/user/${toString sysConfig.users.users.${config.home.username}.uid}";
    # can use the uid... otherwise it's empty for some reason :(
    uid = 1000;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
}
