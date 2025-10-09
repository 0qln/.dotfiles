{osConfig, ...}: {
  programs.nixvim = {
    clipboard = {
      providers.wl-copy.enable = osConfig.services.displayManager.sddm.wayland.enable;
    };
  };
}
