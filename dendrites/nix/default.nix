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

      trustedKeys = mkOption {
        type = types.listOf types.str;
        default = [];
        example = ["dots-push-1:hzd69RP0e91oOy6HkRWlHBIKQa2QCAjo95+gsQlLT64="];
        description = ''
          Extra `trusted-public-keys`, for signers this host accepts paths from
          without also substituting from them. `caches` is the wrong place for
          that, since it additionally registers a substituter.
        '';
      };

      push = {
        enable = mkEnableOption "uploading locally built paths to the binary cache";

        cacheHost = mkOption {
          type = types.str;
          default = "root@lifbrasir";
          description = "ssh destination of the cache host.";
        };

        sshKeyFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = ''
            The sops encrypted ssh private key the drain service authenticates
            with. Needs its own key rather than a user's: the service runs
            unattended as root, while a user key lives under /run/user/<uid>,
            which only exists during a session, and is passphrase protected.
          '';
        };

        signKeyFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = ''
            The sops encrypted nix signing key for locally built paths.
            The cache host refuses to take in unsigned paths even over an
            authenticated ssh connection, so signing here is what makes a push
            land. It is unrelated to how the cache signs what it serves.
          '';
        };

        queueDir = mkOption {
          type = types.str;
          default = "/var/lib/nix-cache-push";
          description = "Where the post build hook leaves paths for the drain service.";
        };

        interval = mkOption {
          type = types.str;
          default = "2min";
          description = "How often the queue is drained.";
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
      #
      # The hook only writes the paths down; a timer does the uploading. Copying
      # inline would hold every build open for the length of its upload, which
      # on a slow uplink is felt on every single build.
      (mkIf cfg.push.enable (let
        queue = "${cfg.push.queueDir}/queue";
      in {
        sops.secrets = mkMerge [
          (mkIf (cfg.push.sshKeyFile != null) {
            "nix/cache-push/sshKey" = {
              sopsFile = cfg.push.sshKeyFile;
              mode = "0400";
              format = "binary";
            };
          })
          (mkIf (cfg.push.signKeyFile != null) {
            "nix/cache-push/signKey" = {
              sopsFile = cfg.push.signKeyFile;
              mode = "0400";
              format = "binary";
            };
          })
        ];

        # signs everything built here, which is what lets the cache host accept it
        nix.settings.secret-key-files =
          mkIf (cfg.push.signKeyFile != null)
          config.sops.secrets."nix/cache-push/signKey".path;

        systemd.tmpfiles.rules = ["d ${queue} 0700 root root - -"];

        nix.settings.post-build-hook = pkgs.writeShellScript "queue-for-cache" ''
          # One file per build, so concurrent builds cannot tear each other's
          # entries and no locking is needed.
          f=$(${pkgs.coreutils}/bin/mktemp "${queue}/XXXXXXXXXX" 2>/dev/null) \
            && printf '%s\n' $OUT_PATHS > "$f"

          # enqueueing must never be able to fail a build
          exit 0
        '';

        systemd.services.nix-cache-push = {
          description = "Upload queued store paths to the binary cache";

          path = [config.nix.package pkgs.openssh pkgs.coreutils pkgs.findutils];

          environment = {
            HOME = "/root";
            NIX_SSHOPTS = concatStringsSep " " ([
                "-o"
                "StrictHostKeyChecking=accept-new"
                "-o"
                "ConnectTimeout=20"
              ]
              ++ optionals (cfg.push.sshKeyFile != null) [
                "-o"
                "IdentitiesOnly=yes"
                "-i"
                config.sops.secrets."nix/cache-push/sshKey".path
              ]);
          };

          serviceConfig = {
            Type = "oneshot";
            User = "root";
          };

          script = ''
            cd ${queue} || exit 0

            # An entry that can never be delivered should not be retried until
            # the end of time.
            find . -maxdepth 1 -type f -mtime +7 -delete

            shopt -s nullglob
            files=(*)
            [ ''${#files[@]} -eq 0 ] && exit 0

            # a queued path may have been collected since it was written down
            paths=$(cat "''${files[@]}" | sort -u | while read -r p; do
              [ -e "$p" ] && printf '%s\n' "$p"
            done)

            if [ -n "$paths" ]; then
              # leave the queue alone on failure, so the next run retries it
              nix copy --to "ssh-ng://${cfg.push.cacheHost}" $paths || exit 1
            fi

            rm -f "''${files[@]}"
          '';
        };

        systemd.timers.nix-cache-push = {
          wantedBy = ["timers.target"];
          timerConfig = {
            OnBootSec = cfg.push.interval;
            OnUnitActiveSec = cfg.push.interval;
            Unit = "nix-cache-push.service";
          };
        };
      }))

      {
        nixpkgs.config.allowUnfree = mkDefault true;

        nix.gc = {
          automatic = mkDefault true;
          dates = mkDefault "weekly";
          persistent = mkDefault true;
          randomizedDelaySec = mkDefault "45min";
          options = mkDefault "--delete-older-than 30d";
        };

        # Hardlinks identical files in the store together. Deliberately a
        # scheduled job rather than `auto-optimise-store`, which does the same
        # work inline and so charges it to every single build instead.
        nix.optimise = {
          automatic = mkDefault true;
          dates = mkDefault ["weekly"];
        };

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
              trusted-public-keys = cfg.trustedKeys;
            }
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
