{inputs, ...}:
with inputs.nixpkgs.lib; {
  # Periodically builds the fleet's configurations straight into the cache
  # host's own store, so the other machines can substitute them instead of
  # compiling.
  #
  # This can sit on the weak machine precisely because nobody waits on it: it
  # runs at the bottom of the scheduler and yields to anything that is actually
  # serving traffic. Interactive builds stay on whichever machine is asking.
  flake.nixosModules.cache-builder = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.modules.cache-builder;
  in {
    options.modules.cache-builder = {
      enable = mkEnableOption "periodic build of the fleet's configurations";

      flakeRef = mkOption {
        type = types.str;
        default = "github:0qln/.dotfiles";
        description = ''
          Built from the remote at the committed revision rather than from a
          working copy, so that what lands in the cache is what another machine
          will evaluate when it switches.
        '';
      };

      gcRoot = mkOption {
        type = types.str;
        default = "/nix/var/nix/gcroots/dots-cache/cache-all";
        description = ''
          Doubles as the build's out-link. Nothing on this host otherwise
          references the other machines' closures, so without a root here they
          are garbage by definition.
        '';
      };

      onCalendar = mkOption {
        type = types.str;
        default = "daily";
        description = "systemd timer OnCalendar specification.";
      };

      randomizedDelaySec = mkOption {
        type = types.str;
        default = "2h";
        description = "Randomized delay for the timer.";
      };

      sshKeyFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          The sops encrypted ssh key used to fetch the private flake input.
          Register the matching public key in gitea as a read only deploy key
          on that repository: this service only ever reads it.
        '';
      };

      memoryHigh = mkOption {
        type = types.str;
        default = "8G";
        description = ''
          Soft memory ceiling for the build. Unlike cpu and io, memory pressure
          does not respect scheduling priority, so a large compile would
          otherwise swap the services out no matter how nice it is.
        '';
      };
    };

    config = mkIf cfg.enable {
      sops.secrets = mkIf (cfg.sshKeyFile != null) {
        "cache-builder/sshKey" = {
          sopsFile = cfg.sshKeyFile;
          mode = "0400";
          format = "binary";
        };
      };

      systemd.services.cache-builder = {
        description = "Build the fleet's configurations into the local store";

        # openssh because the private flake input is fetched over git+ssh
        path = with pkgs; [nix git openssh];

        environment = {
          # nix shells out to git, which shells out to ssh, so the key and the
          # host key policy have to reach it this way.
          HOME = "/root";

          GIT_SSH_COMMAND =
            concatStringsSep " "
            (["ssh" "-o" "StrictHostKeyChecking=accept-new"]
              ++ optionals (cfg.sshKeyFile != null) [
                "-o"
                "IdentitiesOnly=yes"
                "-i"
                config.sops.secrets."cache-builder/sshKey".path
              ]);
        };

        serviceConfig = {
          Type = "oneshot";
          User = "root";

          Nice = 19;
          CPUWeight = 20;
          IOWeight = 20;
          IOSchedulingClass = "idle";
          MemoryHigh = cfg.memoryHigh;
        };

        script = ''
          mkdir -p "$(dirname ${cfg.gcRoot})"

          # One derivation at a time. The bound here is memory, not cpu: the
          # evaluator alone holds ~4G for the whole fleet, and whatever builds
          # alongside it has to fit in what is left of MemoryHigh. Overcommit and
          # the cgroup reclaims its own page cache away to stay under the
          # ceiling, which turns the build into disk thrash that never finishes.
          nix build --max-jobs 1 --out-link ${cfg.gcRoot} "${cfg.flakeRef}#cache-all"
        '';
      };

      systemd.timers.cache-builder = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = cfg.onCalendar;
          Persistent = true;
          RandomizedDelaySec = cfg.randomizedDelaySec;
          Unit = "cache-builder.service";
        };
      };
    };
  };
}
