{pkgs, ...}: {
  home.packages = with pkgs; [
    # tree-sitter
    zig # needs a c compiler
  ];

  programs.nixvim = {
    plugins = {
      treesitter = {
        enable = true;
        nixvimInjections = true;
        folding.enable = false;
        settings = {
          indent.enable = true;
          highlight.enable = true;
        };
      };
      # hmts.enable = true; # tis shit is super buggy :(((((((
    };
  };
}
