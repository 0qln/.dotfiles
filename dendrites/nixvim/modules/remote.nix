{...}: {
  programs.nixvim = {
    plugins = {
      remote-nvim = {
        enable = true;
        settings = {
        };
      };
    };
  };
}
