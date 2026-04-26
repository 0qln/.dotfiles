{inputs, ...}: {
  #
  # Android Development related stuff.
  #

  flake.nixosModules.android = {
    lib,
    config,
    pkgs,
    ...
  }:
    with lib; let
      cfg = config.modules.android;
    in {
      options.modules.android = {
        enable = mkEnableOption "Android stuff";
        android-studio.enable = mkEnableOption "Android Studio";
        users = mkOption {
          type = types.listOf types.str;
          default = [];
        };
      };

      config = mkIf cfg.enable (mkMerge [
        (mkIf cfg.android-studio.enable {
          environment.systemPackages = [
            pkgs.android-studio-full
          ];
          nixpkgs.config.android_sdk.accept_license = true;
        })
        {
          users.users = mkMerge (map (
              user: {
                # https://wiki.nixos.org/wiki/Android#hardware_acceleration
                ${user}.extraGroups = ["kvm"];
              }
            )
            cfg.users);
        }
      ]);
    };
}
