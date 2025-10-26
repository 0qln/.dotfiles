{config, ...}: let
  monitors = config.vars.monitors.devices;
in {
  services.linux-wallpaperengine = {
    enable = true;
    wallpapers = [
      {
        monitor = monitors.center.name;
        wallpaperId = "1512181248";
      }
    ];
  };
}
