{
  pkgs,
  inputs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.flake-upgrader;
  serviceName = "flake-upgrader";
  flake = inputs.self;
in {
  options.modules.flake-upgrader = {
    enable = mkEnableOption "flake-upgrader";

    onCalendar = mkOption {
      type = types.str;
      default = "Sat *-*-* 00:00:00";
      description = ''
        systemd timer OnCalendar specification for when to run garbage collection.
        Default: Weekly on Sunday at midnight.
      '';
    };

    inputs = mkOption {
      type = types.listOf types.str;
      description = "Which inputs to update. The faults to all that don't require credentials.";
      default = let
        # self is not a flake and private requires credentials
        except = ["private" "self"];
        all = builtins.attrNames inputs;
      in
        lists.subtractLists except all;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      shadow
    ];

    programs.git = {
      enable = true;
      config = {
        safe.directory = [flake];
      };
    };

    systemd.services.${serviceName} = {
      after = ["network.target"];
      description = "Flake update and build the system.";
      serviceConfig = {
        User = "root";
        Type = "exec";
        Environment = "PATH=${makeBinPath [pkgs.shadow]}:/run/current-system/sw/bin";
      };
      script = ''
        #!${pkgs.bash}/bin/sh
        cd ${flake}
        nix flake update --commit-lock-file ${concatStringsSep " " cfg.inputs}
      '';
    };

    systemd.timers.${serviceName} = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.onCalendar;
        Persistent = true;
        RandomizedDelaySec = "2h";
        Unit = "${serviceName}.service";
      };
    };
  };
}
