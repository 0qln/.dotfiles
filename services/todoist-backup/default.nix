{
  config,
  lib,
  pkgs,
  ...
}:
let
  serviceName = "todoist-backup";
  serviceUser = "todoist-backup";
  serviceGroup = "todoist-backup";
  servicePkgs = import ./packages.nix { inherit pkgs; };
  service = pkgs.callPackage ./derivation.nix {
    name = serviceName;
    inherit servicePkgs;
  };
in
secrets-env: {
  options.services.${serviceName} = {
    enable = lib.mkEnableOption "Todoist backup service";
  };

  config = lib.mkIf config.services.${serviceName}.enable {
    sops.secrets.${serviceName} = {
      sopsFile = secrets-env;
      owner = serviceUser;
      group = serviceGroup;
      mode = "0400";
      format = "dotenv";
      restartUnits = [ "${serviceName}.service" ];
    };

    # Systemd service definition
    systemd.services.${serviceName} = {
      serviceConfig = {
        Type = "oneshot";
        User = serviceUser;
        EnvironmentFile = "/run/secrets/${serviceName}";
      };
      # Combine script with dependencies
      path = [ service ] ++ servicePkgs;
      script = "${service}/bin/${serviceName}";
    };

    # Scheduled execution
    systemd.timers.${serviceName} = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "2h";
      };
    };

    # Dedicated user
    users.groups.${serviceGroup} = { };
    users.users.${serviceUser} = {
      isSystemUser = true;
      group = serviceGroup;
    };
  };
}
