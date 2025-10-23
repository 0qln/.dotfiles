{config, ...}: {
  sops.secrets."oq/hashedPassword" = {
    sopsFile = ./secrets/password.hash.enc;
    owner = "oq";
    group = "root";
    mode = "0400";
    format = "binary";
  };

  users.users.oq = {
    isNormalUser = true;
    # this is set explicitly such that things like:
    # userRuntimeDir = "/run/user/${toString sysConfig.users.users.${config.home.username}.uid}";
    # can use the uid... otherwise it's empty for some reason :(
    uid = import ./uid.nix;
    extraGroups = [
      "networkmanager"
      "wheel"
      "input" # required for dotool
    ];
    hashedPasswordFile = config.sops.secrets."oq/hashedPassword".path;
  };
}
