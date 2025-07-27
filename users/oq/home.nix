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
# docs:
# https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module
# https://nix-community.github.io/home-manager/options.xhtml#opt-home.activation
# https://github.com/nix-community/home-manager/blob/master/modules/home-environment.nix
    home-manager.users.oq = { pkgs, config, sops-nix, lib, ... }: {
        imports = [
          inputs.zen-browser.homeModules.twilight
          ./hypr/hyprland.nix
        ];
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


        # Configure neovim.

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


        # Configure browsers

        programs.firefox.enable = true;
        programs.zen-browser = {
          enable = true;
          # any other options under `programs.firefox` are also supported here.
          # see `man home-configuration.nix`.
        };


        # Configure git

        programs.git = {
            enable = true;
            userName  = "0qln";
            userEmail = "linusnag@gmail.com";
        };
        # workaround for making the config writable:
        # home.activation = {
        #   replaceWithTarget = lib.hm.dag.entryAfter [ "writeBoundry" ] ''
        #     run cp -RL "${config.xdg.configHome}/git" "${config.xdg.configHome}/git.contents"
        #     run rm -rf "${config.xdg.configHome}/git"
        #     run mv "${config.xdg.configHome}/git.contents" "${config.xdg.configHome}/git"
        #     run chmod -R 755 "${config.xdg.configHome}/git"
        #   '';
        #   # removeExisting = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
        #   #   rm -rf "${config.xdg.configHome}/.config/git/config"
        #   # '';
        #   #
        #   # copy = let
        #   #   new = pkgs.writeText "tmp" (builtins.readFile ./);
        #   # in lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        #   #   rm -rf "/Users/me/.yabairc"
        #   #   cp "${newYabai}" "/Users/me/.yabairc"
        #   #   chmod +x "/Users/me/.yabairc"
        #   # '';
        # };


        # todo: read keys into the files
        # https://github.com/Mic92/sops-nix?tab=readme-ov-file#Flakes
        # waiting for: https://github.com/nix-community/home-manager/issues/3090
        # sops.secrets = {
        #   "oq-sshKeys-server" = { format = "binary"; sopsFile = ./server/id_ed25519; };
        #   "oq-sshKeys-server-pub" = { format = "binary"; sopsFile = ./server/id_ed25519.pub; };
        # };
        # home.file.".ssh/server" = {
        #
        # };


        # Hyprland.

        # home.file.".config/hypr" = {
        #   source = ./hypr;
        #   recursive = true;
        # };

        # imports = [ ./hypr/hyprland.nix ];

        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        home.stateVersion = "25.05"; # Did you read the comment?
    };
}
