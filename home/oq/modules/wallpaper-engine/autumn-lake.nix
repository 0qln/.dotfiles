{ monitors, ... }:
{
  services.linux-wallpaperengine = {
    enable = true;
    wallpapers = [
      {
        monitor = monitors.center;
        wallpaperId = "1512181248";
      }
    ];
  };
}
