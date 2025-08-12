{ pkgs, ... }:
let
  serviceUser = "mysql";
  # DO NOT PUT A TRAILING SLASH AT THE ENDD111!!!
  # (took me an hour to figure this out (i just want to quit and become a farmer... (fml :D)))
  serviceDataDir = "/mnt/store-1/services/mysql";
in
{
  config = {

    users.groups.${serviceUser} = { };
    users.users.${serviceUser} = {
      group = serviceUser;
      isSystemUser = true;
    };

    # ensure files exist with respective permissions
    # docs: https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html#
    # helpful for debugging tmpfiles.d: https://discourse.nixos.org/t/systemd-tmpfiles-does-not-create-files-and-directories/48422/2?u=0qln
    systemd.tmpfiles.rules = [
      "d ${dirOf serviceDataDir} 0755 root root - -"
      "d ${serviceDataDir} 0700 ${serviceUser} ${serviceUser} - -"
    ];

    # options: https://search.nixos.org/options?channel=25.05&show=services.mysql.settings&from=0&size=50&sort=relevance&type=packages&query=services.mysql
    services.mysql = {
      enable = true;
      package = pkgs.mariadb;
      user = serviceUser;
      group = serviceUser;
      dataDir = serviceDataDir;
      settings = {
        # docs:
        # - https://mariadb.com/docs/server/server-management/variables-and-modes/server-system-variables
        # - https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html
        # - https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html
      };
    };
  };
}
