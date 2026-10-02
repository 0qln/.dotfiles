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
      systemd.services.cache-builder = {
        description = "Build the fleet's configurations into the local store";

        # openssh because the private flake input is fetched over git+ssh
        path = with pkgs; [nix git openssh];

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

          nix build --out-link ${cfg.gcRoot} "${cfg.flakeRef}#cache-all"
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
