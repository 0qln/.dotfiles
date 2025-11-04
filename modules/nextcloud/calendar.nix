{config, ...}: {
  services = {
    nextcloud = {
      extraAppsEnable = true;
      extraApps = {
        inherit (config.modules.nextcloud._apps) calendar;
      };
    };
  };
}
