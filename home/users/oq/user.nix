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
    # userRuntimeDir = "/run/user/${toString config.vars.user.uid}/";
    # can use the uid...
    uid = import ./uuid.nix;
    extraGroups = [
      "networkmanager"
      "wheel"
      "input" # required for dotool
    ];
    hashedPasswordFile = config.sops.secrets."oq/hashedPassword".path;
  };
}
