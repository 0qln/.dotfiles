{
  serviceName,
  secrets-env,
  fqdn,
  configFilePath,
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let

  # Documentation:
  #
  # CouchDB obs-livesync specific setup:
  # - https://github.com/vrtmrz/obsidian-livesync/blob/main/docs/setup_own_server.md
  # - https://www.youtube.com/watch?v=7sa_I1832Xc
  # - setup script: https://raw.githubusercontent.com/vrtmrz/obsidian-livesync/main/utils/couchdb/couchdb-init.sh
  #
  # CouchDB general setup:
  # - derivation: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/servers/http/couchdb/3.nix
  # - service: https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/services/databases/couchdb.nix
  # - https://docs.couchdb.org/en/stable/install/unix.html#installing
  # - https://docs.couchdb.org/en/stable/setup/single-node.html
  # - https://docs.couchdb.org/en/stable/intro/security.html
  # - https://github.com/apache/couchdb/issues/2623

  couchdbUser = "couchdb";
  secretsName = "${serviceName}.couchdb";
  hostName = "couchdb.${fqdn}";
  port = 5984;
  initScript = pkgs.callPackage ./couchdb-init.nix { };
  initStateFile = "/var/lib/couchdb/.couchdb-initialized";
  serviceDataDir = "/mnt/store-1/services/couchdb";
in
{
  config = lib.mkIf config.services.${serviceName}.enable {
    environment.systemPackages = with pkgs; [ couchdb3 ];

    systemd.tmpfiles.rules = [
      "d ${dirOf serviceDataDir} 0755 root root - -"
      "d ${serviceDataDir} 0700 ${couchdbUser} ${couchdbUser} - -"
    ];

    # for the setup script:
    sops.secrets.${secretsName} = {
      sopsFile = secrets-env;
      owner = couchdbUser;
      group = couchdbUser;
      mode = "0400";
      format = "dotenv";
      restartUnits = [ "couchdb.service" ];
    };

    # for couchdb local.ini
    sops.secrets."obsidian-livesync/couchdb/local.ini" = {
      sopsFile = configFilePath;
      owner = couchdbUser;
      group = couchdbUser;
      mode = "700";
      format = "binary";
    };

    services.nginx.virtualHosts.${hostName} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${(toString port)}";
      };
    };

    networking.firewall.allowedTCPPorts = [ port ];

    users.groups.${couchdbUser} = { };
    users.users.${couchdbUser} = {
      group = couchdbUser;
      isSystemUser = true;
    };

    services.couchdb = {
      enable = true;
      # We set the admin creds in local.ini manually via sops. See `configFile` below. (like hell I'm gonna use plaintext credentials??? @nixpkga please fix this kalsjdfl;kasjdfl kuj)
      # adminUser = couchdbUser;
      # adminPass = initialAdminPass;
      # extraConfig = ''
      # '';
      #TODO: update this to use the `extraConfigFiles` option.
      configFile = config.sops.secrets."obsidian-livesync/couchdb/local.ini".path;
      user = couchdbUser;
      group = couchdbUser;
      bindAddress = "127.0.0.1";
      inherit port;
      viewIndexDir = serviceDataDir;
      databaseDir = serviceDataDir;
    };

    systemd.services.couchdb-init = {
      after = [ "couchdb.service" ];
      requires = [ "couchdb.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = couchdbUser;
        Type = "oneshot";
        Group = couchdbUser;
        StateDirectory = couchdbUser;
      };

      script = ''
        # Check if we've already initialized
        # Due to the fact that sops nix resets the config file we just run the setup script each time that happens. :)
        # if [ ! -f "${initStateFile}" ]; then
          echo "Initializing CouchDB..."
          export hostname="http://localhost:${(toString port)}"
          source ${config.sops.secrets.${secretsName}.path}
          echo $username

          #TODO: why can the script only read the env vars when it's inlined???
          # ${initScript}/bin/couchdb-init
          # ${pkgs.curl}/bin/curl -s https://raw.githubusercontent.com/vrtmrz/obsidian-livesync/main/utils/couchdb/couchdb-init.sh | ${pkgs.bash}/bin/bash

          # Inlined because of the issue above and:
          # https://github.com/vrtmrz/obsidian-livesync/issues/570
          #
          # <<INLINED BEGIN>>
          #
          if [[ -z "$hostname" ]]; then
              echo "ERROR: Hostname missing"
              exit 1
          fi
          if [[ -z "$username" ]]; then
              echo "ERROR: Username missing"
              exit 1
          fi

          if [[ -z "$password" ]]; then
              echo "ERROR: Password missing"
              exit 1
          fi

          echo "-- Configuring CouchDB by REST APIs... -->"

          until (${pkgs.curl}/bin/curl -X POST "''${hostname}/_cluster_setup" -H "Content-Type: application/json" -d "{\"action\":\"enable_single_node\",\"username\":\"''${username}\",\"password\":\"''${password}\",\"bind_address\":\"0.0.0.0\",\"port\":5984,\"singlenode\":true}" --user "''${username}:''${password}"); do sleep 5; done
          until (${pkgs.curl}/bin/curl -X PUT "''${hostname}/_node/couchdb@127.0.0.1/_config/chttpd/require_valid_user" -H "Content-Type: application/json" -d '"true"' --user "''${username}:''${password}"); do sleep 5; done
          until (${pkgs.curl}/bin/curl -X PUT "''${hostname}/_node/couchdb@127.0.0.1/_config/chttpd_auth/require_valid_user" -H "Content-Type: application/json" -d '"true"' --user "''${username}:''${password}"); do sleep 5; done
          until (${pkgs.curl}/bin/curl -X PUT "''${hostname}/_node/couchdb@127.0.0.1/_config/httpd/WWW-Authenticate" -H "Content-Type: application/json" -d '"Basic realm=\"couchdb\""' --user "''${username}:''${password}"); do sleep 5; done
          until (${pkgs.curl}/bin/curl -X PUT "''${hostname}/_node/couchdb@127.0.0.1/_config/httpd/enable_cors" -H "Content-Type: application/json" -d '"true"' --user "''${username}:''${password}"); do sleep 5; done
          until (${pkgs.curl}/bin/curl -X PUT "''${hostname}/_node/couchdb@127.0.0.1/_config/chttpd/enable_cors" -H "Content-Type: application/json" -d '"true"' --user "''${username}:''${password}"); do sleep 5; done
          until (${pkgs.curl}/bin/curl -X PUT "''${hostname}/_node/couchdb@127.0.0.1/_config/chttpd/max_http_request_size" -H "Content-Type: application/json" -d '"4294967296"' --user "''${username}:''${password}"); do sleep 5; done
          until (${pkgs.curl}/bin/curl -X PUT "''${hostname}/_node/couchdb@127.0.0.1/_config/couchdb/max_document_size" -H "Content-Type: application/json" -d '"50000000"' --user "''${username}:''${password}"); do sleep 5; done
          until (${pkgs.curl}/bin/curl -X PUT "''${hostname}/_node/couchdb@127.0.0.1/_config/cors/credentials" -H "Content-Type: application/json" -d '"true"' --user "''${username}:''${password}"); do sleep 5; done
          until (${pkgs.curl}/bin/curl -X PUT "''${hostname}/_node/couchdb@127.0.0.1/_config/cors/origins" -H "Content-Type: application/json" -d '"app://obsidian.md,capacitor://localhost,http://localhost"' --user "''${username}:''${password}"); do sleep 5; done

          echo "<-- Configuring CouchDB by REST APIs Done!"
          # <<INLINED END>>

          echo "Initialization complete." # State file created: ${initStateFile}"
          # touch "${initStateFile}"
        # else
        #   echo "CouchDB already initialized. Skipping."
        # fi
      '';
    };
  };
}
