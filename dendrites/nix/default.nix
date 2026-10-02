{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.nix = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.modules.nix;
  in {
    options.modules.nix = {
      caches = mkOption {
        type = types.attrs;
        default = {};
        example = {
          "hyprland.cachix.org" = "a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
        };
      };

      netrcFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          The sops encrypted netrc holding credentials for the substituters in
          `caches`. Kept out of the substituter urls themselves, since a
          https://user:pass@host url ends up world readable in the nix store.
        '';
      };

      push = {
        enable = mkEnableOption "uploading locally built paths to the binary cache";

        cacheHost = mkOption {
          type = types.str;
          default = "root@lifbrasir";
          description = ''
            ssh destination of the cache host. The nix daemon runs the hook as
            root, so root's key here has to be authorized over there, and root
            has to be a trusted nix user on the far side.
          '';
        };
      };
    };

    config = mkMerge [
      # kept as a whole conditional definition rather than an empty attrset, so
      # that hosts which never import the sops module still evaluate.
      (mkIf (cfg.netrcFile != null) {
        sops.secrets."nix/netrc" = {
          sopsFile = cfg.netrcFile;
          mode = "0400";
          format = "binary";
        };

        nix.settings.netrc-file = config.sops.secrets."nix/netrc".path;
      })

      # Whatever this host could not substitute, it builds itself and sends up,
      # so the next machine that wants it does not have to build it again.
      (mkIf cfg.push.enable {
        nix.settings.post-build-hook = pkgs.writeShellScript "push-to-cache" ''
          set -eu

          # the daemon runs hooks with a bare environment, and ssh needs both
          export HOME=/root
          export PATH=${makeBinPath [config.nix.package pkgs.openssh]}:$PATH

          # Never fail a build over an unreachable cache: a laptop away from
          # home would otherwise not be able to build anything at all.
          nix copy --to "ssh-ng://${cfg.push.cacheHost}" $OUT_PATHS \
            || echo "cache push to ${cfg.push.cacheHost} failed, continuing" >&2
        '';
      })

      {
        nixpkgs.config.allowUnfree = mkDefault true;

        nix.settings = mkMerge (
          (let
            mkSubstituter = fqdn: key: {
              substituters = ["https://${fqdn}"];
              trusted-substituters = ["https://${fqdn}"];
              trusted-public-keys = ["${fqdn}-1:${key}"];
            };
          in
            attrsets.mapAttrsToList mkSubstituter cfg.caches)
          ++ [
            {
              trusted-users = ["root" "@wheel"];
            }
            {
              experimental-features = [
                "nix-command"
                "flakes"
              ];
            }
            {
              experimental-features = [
                "pipe-operators"
              ];
            }
          ]
        );
      }
    ];
  };

  flake.homeModules.nix = {pkgs, ...}: {
    imports = [
      inputs.nix-index-database.homeModules.default
    ];

    config = {
      nixpkgs.config.allowUnfree = mkDefault true;

      programs.nix-index-database.comma.enable = true;

      home.packages = with pkgs; [
        nurl
        nix-init
      ];
    };
  };
}
