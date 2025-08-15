{
  serviceName,
  secrets-env,
  fqdn,
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Documentation:
  # https://github.com/vrtmrz/obsidian-livesync/blob/main/docs/setup_own_server.md
  # https://docs.couchdb.org/en/stable/install/unix.html#installing
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/servers/http/couchdb/3.nix
  # https://www.youtube.com/watch?v=7sa_I1832Xc
  couchdbUser = "couchdb";
  secretsName = "${serviceName}.couchdb";
  address = "localhost";
  hostName = "couchdb.${fqdn}";
  port = 5984;
  initScript = pkgs.callPackage ./couchdb-init.nix { };
  initStateFile = "/var/lib/couchdb/.couchdb-initialized";
in
{
  config = lib.mkIf config.services.${serviceName}.enable {
    environment.systemPackages = with pkgs; [ couchdb3 ];

    sops.secrets.${secretsName} = {
      sopsFile = secrets-env;
      owner = couchdbUser;
      group = couchdbUser;
      mode = "0400";
      format = "dotenv";
      restartUnits = [ "couchdb.service" ];
    };

    services.nginx.virtualHosts.${hostName} = {
      locations."/" = {
        proxyPass = "http://${address}:${(toString port)}";
      };
    };

    networking.firewall.allowedTCPPorts = [ port ];

    users.groups.${couchdbUser} = { };
    users.users.${couchdbUser} = {
      group = couchdbUser;
      isSystemUser = true;
      home = "/home/${couchdbUser}";
      createHome = true;
      shell = pkgs.bash;
    };

    services.couchdb = {
      enable = true;
      adminUser = couchdbUser;
      user = couchdbUser;
      group = couchdbUser;
      bindAddress = address;
      inherit port;
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
        if [ ! -f "${initStateFile}" ]; then
          echo "Initializing CouchDB..."
          export hostname="${address}:${(toString port)}"
          source /run/secrets/${secretsName}
          ${initScript}/bin/couchdb-init
          echo "Initialization complete. State file created: ${initStateFile}"
          touch "${initStateFile}"
        else
          echo "CouchDB already initialized. Skipping."
        fi
      '';
    };
  };
}
