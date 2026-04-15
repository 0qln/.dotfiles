{
  inputs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.users.oq;
in {
  imports = [
    inputs.private.nixosModules."oq"
  ];

  options.users.oq = {
    enable = mkEnableOption "the oq user";
    uuid = mkOption {
      type = types.int;
      default = 1000;
      description = "The UID for the oq user.";
    };
    password.hashFile = mkOption {
      type = types.path;
      description = "The sops encrypted file that contains the hashed password for the user.";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."oq/hashedPassword" = {
      sopsFile = cfg.password.hashFile;
      owner = "oq";
      group = "root";
      mode = "0400";
      format = "binary";
    };

    home-manager.users.oq = mkMerge [
      (import ./home.nix)
      {
        # when building on standalone home-manager, the uid could be set as an external
        # argument as per-host. cause it might be different
        vars.user = {uid = mkForce cfg.uuid;};
      }
    ];

    users.users.oq = {
      isNormalUser = true;
      # this is set explicitly such that things like:
      # userRuntimeDir = "/run/user/${toString config.vars.user.uid}/";
      # can use the uid...
      uid = cfg.uuid;
      extraGroups = [
        "networkmanager"
        "wheel"
        "input" # required for dotool
      ];
      hashedPasswordFile = config.sops.secrets."oq/hashedPassword".path;
    };
  };
}
