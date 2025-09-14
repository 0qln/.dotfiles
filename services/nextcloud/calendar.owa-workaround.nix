{
  nextcloudEnvFile,
  onCalendar ? "@hourly",
}: {
  pkgs,
  config,
  ...
}: let
  serviceName = "owa-calendar-sync";
  secretsName = "${serviceName}/nextcloudEnvFile";
  serviceUser = "nextcloud-owa-calender-sync";
  servicePkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-22.11.tar.gz";
    sha256 = "1xi53rlslcprybsvrmipm69ypd3g3hr7wkxvzc73ag8296yclyll";
  };
in {
  config = {
    users.groups.${serviceUser} = {};
    users.users.${serviceUser} = {
      group = serviceUser;
      isSystemUser = true;
    };

    sops.secrets = {
      ${secretsName} = {
        sopsFile = nextcloudEnvFile;
        owner = serviceUser;
        group = serviceUser;
        mode = "0400";
        format = "dotenv";
      };
    };

    systemd.services.${serviceName} = {
      after = ["network.target" "nextcloud.service"];
      description = "";
      serviceConfig = {
        User = serviceUser;
        Type = "exec";
        Environment = "PATH=${pkgs.lib.makeBinPath [pkgs.curl pkgs.nix pkgs.python3]}:/run/current-system/sw/bin";
        RuntimeDirectory = serviceName;
      };
      script = ''
        # vars
        source ${config.sops.secrets.${secretsName}.path}

        # Use runtime directory instead of /tmp
        RUNTIME_DIR="/run/${serviceName}"
        [ -z "$ICS_FILE_PATH" ] && export ICS_FILE_PATH="$RUNTIME_DIR/calendar.ics"

        # download .ics from owa url
        echo "Fetching calendar from $ICS_OWLCAL_URL"
        curl "$ICS_OWLCAL_URL" \
          --compressed \
          -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:142.0) Gecko/20100101 Firefox/142.0' \
          -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
          -H 'Accept-Language: en-US,en;q=0.5' \
          -H 'Accept-Encoding: gzip, deflate, br, zstd' \
          -H 'DNT: 1' \
          -H 'Sec-GPC: 1' \
          -H 'Connection: keep-alive' \
          -H 'Upgrade-Insecure-Requests: 1' \
          -H 'Sec-Fetch-Dest: document' \
          -H 'Sec-Fetch-Mode: navigate' \
          -H 'Sec-Fetch-Site: none' \
          -H 'Sec-Fetch-User: ?1' \
          -H 'Priority: u=0, i' \
          -o "$ICS_FILE_PATH"

        head "$ICS_FILE_PATH"

        # execute sync
        nix-shell \
          -I "nixpkgs=${toString servicePkgs}" \
          "${./owa-calendar-sync.shell.nix}" \
          --run "python3 ${./owa-calendar-sync.py}"

        # clean up
        rm "$ICS_FILE_PATH"
      '';
    };

    systemd.timers.${serviceName} = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = onCalendar;
        Persistent = true;
        RandomizedDelaySec = "15m";
        Unit = "${serviceName}.service";
      };
    };
  };
}
