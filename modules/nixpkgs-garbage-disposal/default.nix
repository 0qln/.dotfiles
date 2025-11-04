{
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.nixpkgs-garbage-disposal;
  serviceName = "nixpkgs-garbage-disposal";
  flake = inputs.self;
in {
  options.modules.nixpkgs-garbage-disposal = {
    enable = mkEnableOption "Nixpkgs garbage disposal service";

    onCalendar = mkOption {
      type = types.str;
      default = "Sun *-*-* 00:00:00";
      description = ''
        systemd timer OnCalendar specification for when to run garbage collection.
        Default: Weekly on Sunday at midnight.
      '';
    };

    olderThan = mkOption {
      type = types.str;
      default = "14d";
      description = ''
        Delete generations older than specified time.
        Default: 14 days (14d).
      '';
    };

    rebuildCmd = mkOption {
      type = types.str;
      # won't work if flake output attr name != current hostname
      default = "cd ${flake} && nixos-rebuild boot --flake .";
      description = ''
        The rebuild command to execute after the gc.
      '';
    };

    randomizedDelaySec = mkOption {
      type = types.str;
      default = "2h";
      description = ''
        Randomized delay for the timer to avoid system load spikes.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.${serviceName} = {
      description = "Garbage disposal for the nix/store";

      serviceConfig = {
        User = "root";
        Type = "oneshot";
        Environment = "PATH=/run/current-system/sw/bin";
      };

      script = ''
        echo "Starting nix garbage collection..."

        nix-collect-garbage --delete-older-than ${cfg.olderThan}
        echo "garbage collection completed successfully"

        ${cfg.rebuildCmd}
        echo "successfully rebuild the system"
      '';
    };

    systemd.timers.${serviceName} = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.onCalendar;
        Persistent = true;
        RandomizedDelaySec = cfg.randomizedDelaySec;
        Unit = "${serviceName}.service";
      };
    };
  };
}
