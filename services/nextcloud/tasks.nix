{config, ...}: {
  services = {
    nextcloud = {
      extraAppsEnable = true;
      extraApps = {
        inherit (config.services.my-nextcloud._apps) tasks;
      };
    };
  };
}
