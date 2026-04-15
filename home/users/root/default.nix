{
  inputs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.users.root;
in {
  imports = [
    inputs.private.nixosModules."root"
  ];

  options.users.root = {
    enable = mkEnableOption "the root user";
    uuid = mkOption {
      type = types.int;
      default = 0;
      description = "The UID for the root user.";
    };
    password.hashFile = mkOption {
      type = types.path;
      description = "The sops encrypted file that contains the hashed password for the user.";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."root/hashedPassword" = {
      sopsFile = cfg.password.hashFile;
      owner = "root";
      group = "root";
      mode = "0400";
      format = "binary";
    };

    home-manager.users.root = mkMerge [
      (import ./home.nix)
      {vars.user = {uid = mkForce cfg.uuid;};}
    ];

    users.users.root = {
      uid = cfg.uuid;
      hashedPasswordFile = config.sops.secrets."root/hashedPassword".path;
    };
  };
}
