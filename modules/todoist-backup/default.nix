{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.todoist-backup;

  serviceName = "todoist-backup";
  serviceUser = "todoist-backup";
  serviceGroup = "todoist-backup";
  servicePkgs = import ./packages.nix {inherit pkgs;};
  service = pkgs.callPackage ./derivation.nix {
    name = serviceName;
    inherit servicePkgs;
  };
in {
  options.modules.${serviceName} = {
    enable = mkEnableOption "Todoist backup service";
    secretsEnvFile = mkOption {
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.${serviceName} = {
      sopsFile = cfg.secretsEnvFile;
      owner = serviceUser;
      group = serviceGroup;
      mode = "0400";
      format = "dotenv";
      restartUnits = ["${serviceName}.service"];
    };

    # Systemd service definition
    systemd.services.${serviceName} = {
      serviceConfig = {
        Type = "oneshot";
        User = serviceUser;
        EnvironmentFile = "/run/secrets/${serviceName}";
      };
      # Combine script with dependencies
      path = [service] ++ servicePkgs;
      script = "${service}/bin/${serviceName}";
    };

    # Scheduled execution
    systemd.timers.${serviceName} = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "2h";
      };
    };

    # Dedicated user
    users.groups.${serviceGroup} = {};
    users.users.${serviceUser} = {
      isSystemUser = true;
      group = serviceGroup;
    };
  };
}
