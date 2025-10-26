{config, ...}: {
  sops.secrets."root/hashedPassword" = {
    sopsFile = ./secrets/password.hash.enc;
    owner = "root";
    group = "root";
    mode = "0400";
    format = "binary";
  };

  users.users.root = {
    uid = import ./uuid.nix;
    hashedPasswordFile = config.sops.secrets."root/hashedPassword".path;
  };
}
