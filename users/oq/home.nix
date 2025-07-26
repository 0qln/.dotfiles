{ home-manager, lib, inputs, self, ... }:
let
    #todo: move to a utils module at flake rootStr
    #todo: use this and don't hardcode the root path: https://github.com/srid/flake-root
    # source: https://github.com/nix-community/home-manager/issues/257#issuecomment-1646557848
    # related: https://discourse.nixos.org/t/neovim-config-read-only/35109/10
    runtimeRoot = "/home/oq/.dotfiles";
    runtimePath = path:
      let
        # This is the `self` that gets passed to a flake `outputs`.
        rootStr = toString self;
        pathStr = toString path;
      in
      assert lib.assertMsg
        (lib.hasPrefix rootStr pathStr)
        "${pathStr} does not start with ${rootStr}";
      runtimeRoot + lib.removePrefix rootStr pathStr;
in {
    home-manager.users.oq = { pkgs, config, ... }: {
        home.packages = with pkgs; [
            kdePackages.kate

            obsidian

            todoist-electron

            git
            gh

            tree

            gcc

            #neovim
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
            imagemagick
            jdt-language-server
        ];

        programs.neovim = {
            enable = true;
            viAlias = true;
            vimAlias = true;
            vimdiffAlias = true;
        };

        # Setting session variables normally is broken when using home-manager ;(
        # context: https://github.com/nix-community/home-manager/issues/1011
        programs.bash = {
          enable = true; 
          initExtra = ''
            export EDITOR="nvim"
          '';
        };

        home.file.".config/nvim" = {
            source = config.lib.file.mkOutOfStoreSymlink (runtimePath ./nvim);
            recursive = true;
        };

        programs.firefox.enable = true;

        programs.git = {
            enable = true;
            userName  = "0qln";
            userEmail = "linusnag@gmail.com";
        };

        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        home.stateVersion = "25.05"; # Did you read the comment?
    };
}
