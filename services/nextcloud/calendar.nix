{apps}: {pkgs, ...}: {
  services = {
    nextcloud = {
      extraAppsEnable = true;
      extraApps = {
        inherit (apps) calendar;
      };
    };
  };
}
