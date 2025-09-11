{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      everforest
      rose-pine
      melange-nvim
      kanagawa-nvim
      kanagawa-paper-nvim

      #TODO:
      # https://github.com/ramojus/mellifluous.nvim
      # https://github.com/dgox16/oldworld.nvim
      # https://github.com/everviolet/nvim
      # https://github.com/vague2k/vague.nvim
    ];
    colorschemes."kanagawa".enable = true;
  };
}
