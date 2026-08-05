{...}: {
  programs.nixvim = {
    opts = {
      undofile = true;
    };
    plugins = {
      undotree.enable = true;
    };
  };
}
