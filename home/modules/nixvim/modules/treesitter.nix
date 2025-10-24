{pkgs, ...}: {
  home.packages = with pkgs; [
    tree-sitter
    zig # needs a c compiler
  ];

  programs.nixvim = {
    plugins = {
      treesitter = {
        enable = true;
        nixvimInjections = true;
        folding = false;
        settings = {
          indent.enable = true;
          highlight.enable = true;
        };
        grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
      };
      treesitter-refactor = {
        enable = true;
        settings = {
          highlight_definitions = {
            enable = true;
            clear_on_cursor_move = false;
          };
        };
      };
      # hmts.enable = true; # tis shit is super buggy :(((((((
    };
  };
}
