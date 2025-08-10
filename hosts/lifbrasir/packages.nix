{ pkgs, ... }:
{

  # List packages installed in system profile. To search, run:
  #TODO: clean this
  environment.systemPackages = with pkgs; [
    vim
    neovim
    git
    gcc
    cmake
    tmux
    wget
    upower
    tlp
    tree
    unzip
    fzf
    vimPlugins.vim-markdown-toc
    markdownlint-cli2
    prettierd
    sqlfluff
    stylua
    ast-grep
    ripgrep
    python313
    python313Packages.pip
    luarocks
    lua
    fd
    lazygit
    go
    tree-sitter
    nodejs_24
    rustup
    rustc
    cargo
    imagemagick
    jdt-language-server
    gh
    sops
  ];

}
