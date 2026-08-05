{...}: {
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
    keymaps = [
      # Lazy git
      {
        action = "<cmd>LazyGit<cr>";
        key = "<leader>lg";
        options = {
          desc = "LazyGit";
        };
      }
      # git blame open URL
      {
        action = "<cmd>GitBlameOpenCommitURL<CR>";
        key = "<leader>gb";
        options = {
          silent = true;
          noremap = true;
          desc = "Open git blame URL";
        };
      }
    ];
    plugins = {
      lazygit = {
        enable = true;
      };
      gitblame.enable = true;
    };
  };
}
