{config, ...}: {
  programs.nixvim = {
    clipboard = {
      providers.wl-copy.enable = config.modules.hypr.enable;
    };
  };
}
