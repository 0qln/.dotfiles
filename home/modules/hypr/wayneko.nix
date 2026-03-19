{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.hypr.wayneko;

  # https://github.com/NixOS/nixpkgs/issues/501211
  oldPkgs = (builtins.getFlake "github:NixOS/nixpkgs/fbcf476f790d8a217c3eab4e12033dc4a0f6d23c").legacyPackages.${pkgs.stdenv.hostPlatform.system};
  inherit (oldPkgs) wayneko;
in
  with lib; {
    options.modules.hypr.wayneko = {
      enable = config.utils.mkEnableOption "hypr.wayneko" config.modules.hypr.enable;
      count = mkOption {
        type = types.ints.unsigned;
        default = 2;
        description = "how many do we want? :3";
      };
    };

    config = mkIf cfg.enable {
      home.packages = [
        wayneko
      ];

      systemd.user.services = let
        range = lists.range 1 cfg.count;
        mkWayneko = n: (nameValuePair "wayneko-${n}" {
          Unit = {
            Description = "Wayneko Nr. ${n}";
            After = ["graphical-session.target"];
          };

          Service = {
            ExecStart = "${pkgs.writeShellScript "wayneko-${n}-start" ''
              SLEEPINESS=$(( RANDOM % 5 + 1 )) # random sleepiness between 1-5
              ${getExe wayneko} --layer top --follow-pointer true --type neko --sleepiness $SLEEPINESS
            ''}";
          };

          Install = {
            WantedBy = ["graphical-session.target"];
          };
        });
      in
        builtins.listToAttrs (map (i: i |> toString |> mkWayneko) range);
    };
  }
