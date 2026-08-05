{...}: {
  programs.nixvim = {
    plugins = {
      #TODO: configure more dap
      dap.enable = true;
      dap-ui.enable = true;
      dap-virtual-text.enable = true;
    };
  };
}
