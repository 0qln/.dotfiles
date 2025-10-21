{...}: {
  programs.nixvim = {
    diagnostic.settings = {
      signs = false;
    };
  };
}
