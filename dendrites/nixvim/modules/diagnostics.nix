{...}: {
  programs.nixvim = {
    diagnostic.settings = {
      update_in_insert = false;
    };
  };
}
