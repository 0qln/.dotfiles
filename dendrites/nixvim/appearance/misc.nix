{...}: {
  programs.nixvim = {
    opts = {
      # cursor scroll off
      scrolloff = 8;

      # actiavate conceal
      conceallevel = 1;

      # show relative line numbers
      relativenumber = true;
      number = true;
    };
  };
}
