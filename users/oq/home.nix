{
  lib,
  inputs,
  self,
  ...
}:
let
  #TODO: move to a utils module at flake rootStr
  #TODO: use this and don't hardcode the root path: https://github.com/srid/flake-root
  # source: https://github.com/nix-community/home-manager/issues/257#issuecomment-1646557848
  # related: https://discourse.nixos.org/t/neovim-config-read-only/35109/10
  runtimeRoot = "/home/oq/.dotfiles";
  runtimePath =
    path:
    let
      # This is the `self` that gets passed to a flake `outputs`.
      rootStr = toString self;
      pathStr = toString path;
    in
    assert lib.assertMsg (lib.hasPrefix rootStr pathStr) "${pathStr} does not start with ${rootStr}";
    runtimeRoot + lib.removePrefix rootStr pathStr;
in
{
  # docs:
  # https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module
  # https://nix-community.github.io/home-manager/options.xhtml#opt-home.activation
  # https://github.com/nix-community/home-manager/blob/master/modules/home-environment.nix
  home-manager.users.oq =
    {
      pkgs,
      config,
      sops-nix,
      lib,
      sysConfig,
      ...
    }:
    let
      #TODO: use this utils file, ressources are here: https://discourse.nixos.org/t/can-anyone-help-explain-to-me-how-i-pass-values-in-nix/43117
      # utils = pkgs.callPackage ./utils { inherit lib sysConfig; };
      # runtimeDir = utils.userRuntimeDir;

      userRuntimeDir = "/run/user/${toString sysConfig.users.users.${config.home.username}.uid}";
    in
    {
      sops = {
        defaultSopsFormat = "yaml";
        age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
        defaultSymlinkPath = "${userRuntimeDir}/secrets";
        defaultSecretsMountPoint = "${userRuntimeDir}/secrets.d";
      };

      imports = [
        inputs.zen-browser.homeModules.twilight
        inputs.nixvim.homeModules.nixvim
        inputs.sops-nix.homeManagerModules.sops
        ./hypr
        ./btop
        ./git
        ./lf
        ./todoist
        ./youtube-music
        ./rofi
      ];

      home.packages = with pkgs; [
        sops

        qimgv

        obsidian

        git
        gh

        tree

        gcc

        fzf

        unzip
        vimPlugins.vim-markdown-toc
        markdownlint-cli2
        prettierd
        sqlfluff
        # stylua
        ast-grep
        ripgrep
        python313
        python313Packages.pip
        # luarocks
        # lua
        fd
        go
        tree-sitter
        nodejs_24
        rustup
        rustc
        imagemagick
        jdt-language-server

        ffmpeg
        imagemagick

        wallust
      ];

      # direnv
      programs.direnv = {
        enable = true;
      };

      # Configure neovim.

      # just in case i want to do it via copying my lua config again:
      # - https://github.com/Kidsan/nixos-config/blob/main/home/programs/neovim/nvim/lua/kidsan/set.lua
      # - https://github.com/samiulbasirfahim/flakes/blob/main/home/rxen/neovim/config/init.lua

      # docs:
      # inspiration:
      #   - https://github.com/LazyVim/LazyVim/blob/25abbf546d564dc484cf903804661ba12de45507/lua/lazyvim/plugins/ui.lua#L12
      #   - https://github.com/Ahwxorg/nixvim-config/blob/fe2f1c27fa532489800b8f4d17f12c13299afa8d/config/modules/plugins/lsp.nix#L6
      #   - https://github.com/bkp5190/Home-Manager-Configs/blob/main/plugins/default.nix
      #   - https://github.com/elythh/nixvim
      # nixvim options:
      #   - https://nix-community.github.io/nixvim/NeovimOptions/index.html

      # in case i want to do lazy loading some day:
      #   - https://github.com/nvim-neorocks/lz.n

      programs.nixvim = {
        enable = true;

        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        defaultEditor = true;

        extraPackages = [ ];

        globals = {
          mapleader = " ";
          maplocalleader = " ";
        };

        keymaps = [
          {
            action = ">gv";
            key = ">";
            mode = [ "v" ];
          }
          {
            action = "<gv";
            key = "<";
            mode = [ "v" ];
          }
          # # cmp for : or / or ? modes
          # {
          #   action = "<cmd>lua require('cmp').mapping.confirm({ select = true })<cr>";
          #   key = "<tab>";
          #   mode = [ "c" ];
          # }
          # oil mapping for file tree
          {
            action = ":Oil<CR>";
            key = "<leader>o";
            options = {
              silent = true;
              noremap = true;
              desc = "Oil Mapping";
            };
          }
          # Coda action
          {
            action = "lua vim.lsp.buf.code_action()<CR>";
            key = "<leader>ca";
            mode = [
              "n"
              "v"
            ];
            options = {
              desc = "Code Action";
            };
          }
          # Code format
          {
            action = "lua vim.lsp.buf.format()<CR>";
            key = "<leader>cf";
            mode = [
              "n"
              "v"
            ];
            options = {
              desc = "Code Format";
              noremap = true;
            };
          }
          # Go to definition
          {
            action = ":lua vim.lsp.buf.definition()<CR>";
            key = "gd";
            options = {
              silent = true;
              noremap = true;
              desc = "Go to definition";
            };
          }
          # Go to references
          {
            action = ":lua vim.lsp.buf.references()<CR>";
            key = "gr";
            options = {
              silent = true;
              noremap = true;
              desc = "Go to references";
            };
          }
          # git blame open URL
          {
            action = ":GitBlameOpenCommitURL<CR>";
            key = "<leader>gb";
            options = {
              silent = true;
              noremap = true;
              desc = "Open git blame URL";
            };
          }
          # Telescope search (live grep)
          {
            action = ":Telescope live_grep<CR>";
            key = "<leader>/";
            options = {
              silent = true;
              noremap = true;
              desc = "Search grep";
            };
          }
          # Telescope search buffers
          {
            action = ":Telescope buffers<CR>";
            key = "<leader>sb";
            options = {
              silent = true;
              noremap = true;
              desc = "Search buffers";
            };
          }
          # Telescope search commands
          {
            action = ":Telescope command_history<CR>";
            key = "<leader>sc";
            options = {
              silent = true;
              noremap = true;
              desc = "Search commands";
            };
          }
          # Telescope search files
          {
            action = ":Telescope find_files<CR>";
            key = "<leader><leader>";
            options = {
              silent = true;
              noremap = true;
              desc = "Search files";
            };
          }
          # Telescope quickfixlist
          {
            action = ":Telescope quickfix<CR>";
            key = "<leader>ql";
            options = {
              silent = true;
              noremap = true;
              desc = "Quickfix list";
            };
          }
          # Telescope undo tree
          {
            action = ":UndotreeToggle<CR>";
            key = "<leader>u";
            options = {
              silent = true;
              noremap = true;
              desc = "Undo tree";
            };
          }
          # Mapping q for recording macros
          {
            action = "q";
            key = "q";
            options = {
              silent = true;
              noremap = true;
            };
          }
          # Mapping Ctrl+V for block visual mode
          {
            action = "<C-v>";
            key = "<C-v>";
            options = {
              silent = true;
              noremap = true;
            };
          }
          # Buffers
          {
            action = "<cmd>bnext<CR>";
            key = "<S-l>";
            options = {
              silent = true;
              noremap = true;
              desc = "Next buffer";
            };
          }
          {
            action = "<cmd>bprev<CR>";
            key = "<S-h>";
            options = {
              silent = true;
              noremap = true;
              desc = "Prev buffer";
            };
          }
          {
            action = "<cmd>e #<cr>";
            key = "<leader>bb";
            options = {
              desc = "Switch to other buffer";
            };
          }
          {
            action = "<cmd>bd<cr>";
            key = "<leader>bd";
            options = {
              desc = "Close current buffer";
            };
          }

          {
            action = ":vsplit<CR>";
            key = "<leader>s";
            options = {
              silent = true;
              noremap = true;
              desc = "Vertical Split";
            };
          }
          {
            action = "<C-w>h";
            key = "<C-h>";
            options = {
              silent = true;
              noremap = true;
              desc = "Move to the pane on the left";
            };
          }
          {
            action = "<C-w>l";
            key = "<C-l>";
            options = {
              silent = true;
              noremap = true;
              desc = "Move to the pane on the right";
            };
          }
          {
            action = "<C-w>j";
            key = "<C-j>";
            options = {
              silent = true;
              noremap = true;
              desc = "Move to the pane below";
            };
          }
          {
            action = "<C-w>k";
            key = "<C-k>";
            options = {
              silent = true;
              noremap = true;
              desc = "Move to the pane above";
            };
          }
          {
            action = ":Trouble diagnostics toggle<CR>";
            key = "<leader>tt";
            options = {
              silent = true;
              noremap = true;
              desc = "Open trouble diagnostics";
            };
          }
          #DAP
          {
            key = "<leader>db";
            action = ":DapToggleBreakpoint<CR>";
            options = {
              silent = true;
              noremap = true;
              desc = "Toggle breakpoint";
            };
          }
          {
            key = "<leader>dB";
            action = ":DapClearBreakpoints<CR>";
            options = {
              silent = true;
              noremap = true;
              desc = "Clear all breakpoints";
            };
          }
          {
            key = "<leadr>dc";
            action = ":DapContinue<CR>";
            options = {
              silent = true;
              noremap = true;
              desc = "Start/Continue debugging";
            };
          }
          {
            key = "<leader>dso";
            action = ":DapStepOver<CR>";
            options = {
              silent = true;
              noremap = true;
              desc = "Step over";
            };
          }
          {
            key = "<leader>dsi";
            action = ":DapStepInto<CR>";
            options = {
              silent = true;
              noremap = true;
              desc = "Step into";
            };
          }
          {
            key = "<leader>dsO";
            action = ":DapStepOut<CR>";
            options = {
              silent = true;
              noremap = true;
              desc = "Step out";
            };
          }
          {
            key = "<leader>dr";
            action = "<cmd>lua require('dap').run_to_cursor()<CR>";
            options = {
              silent = true;
              noremap = true;
              desc = "Run to cursor";
            };
          }
          {
            key = "<leader>du";
            action = "<cmd>lua require('dapui').toggle()<CR>";
            options = {
              silent = true;
              noremap = true;
              desc = "Toggle DAP UI";
            };
          }
          {
            key = "<leader>dR";
            action = "<cmd>lua require('dap').restart()<CR>";
            options = {
              silent = true;
              noremap = true;
              desc = "Restart debugging session";
            };
          }
          {
            mode = "n";
            key = "<C-t>";
            action.__raw = ''
              function()
                require('telescope.builtin').live_grep({
                  default_text="TODO",
                  initial_mode="normal"
                })
              end
            '';
            options.silent = true;
          }
        ];

        # transparent bufferline
        extraConfigLuaPost = ''
          -- transparent bufferline
          vim.g.transparent_groups = vim.list_extend(
          vim.g.transparent_groups or {},
            vim.tbl_map(function(v)
              return v.hl_group
            end, vim.tbl_values(require('bufferline.config').highlights))
          )


          -- cmp

          local cmp = require'cmp'

          -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
          cmp.setup.cmdline({'/', "?" }, {
            sources = {
              { name = 'buffer' }
            }
          })

          -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
          cmp.setup.cmdline(':', {
            sources = cmp.config.sources({
              { name = 'async-path' }
            }, {
              { name = 'cmdline' }
            }),
          })
        '';

        # in case lualine is opaque again:
        #https://www.reddit.com/r/neovim/comments/s4ud1d/comment/hsvesja/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

        # cmp

        plugins = {

          # inspiration: https://github.com/dc-tec/nixvim/blob/main/config/plugins/cmp/cmp.nix

          cmp-emoji.enable = true;
          cmp_luasnip.enable = true;
          cmp-cmdline.enable = true;
          cmp-buffer.enable = true;
          cmp-nvim-lsp.enable = true;
          cmp-async-path.enable = true;

          schemastore = {
            enable = true;
            yaml.enable = true;
            json.enable = false;
          };

          # github: https://github.com/hrsh7th/nvim-cmp?tab=readme-ov-file
          # nixvim: https://nix-community.github.io/nixvim/plugins/cmp/index.html#cmp
          cmp = {
            enable = true;
            autoEnableSources = true;
            settings = {
              performance = {
                maxViewEntries = 8;
              };
              sources = [
                # sources: https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources
                { name = "nvim_lsp"; }
                { name = "cmp_lsp_rs"; }
                # go-lang: go_deep
                { name = "nvim_lsp_signature_help"; }
                { name = "nvim_lsp_document_symbol"; }
                { name = "diag-codes"; }
                { name = "async_path"; }
                { name = "buffer"; }
                { name = "luasnip"; }
                #TODO: https://github.com/lukas-reineke/cmp-rg?tab=readme-ov-file
                #TODO: https://github.com/tzachar/cmp-ai
                { name = "emoji"; }
                { name = "cmdline"; }
                #TODO: cmp-tw2css does not exist on nixvim?
              ];
              snippet = {
                expand = "luasnip";
              };
              window = {
                completion = {
                  border = "solid";
                };
                documentation = {
                  border = "solid";
                };
              };
              mapping = {
                "<C-j>" = "cmp.mapping.select_next_item()";
                "<C-k>" = "cmp.mapping.select_prev_item()";
                "<C-e>" = "cmp.mapping.abort()";
                "<C-b>" = "cmp.mapping.scroll_docs(-4)";
                "<C-f>" = "cmp.mapping.scroll_docs(4)";
                "<tab>" = "cmp.mapping.confirm({ select = true })";
              };
            };
            #TODO
            # settings.sorting = {
            #   comparators = [
            #     ''function(...) return cmp_buffer:compare_locality(...) end''
            #   ];
            # };
            #cmdline = {
            #  #TODO: https://github.com/hrsh7th/cmp-cmdline
            #};
          };

          commentary.enable = true;
          bufferline = {
            enable = true;
          };
          undotree.enable = true;
          # did have glitches, so nononoo
          # smear-cursor = {
          #   enable = true;
          #   settings = {
          #     stiffness = 0.8; # :                     # 0.6      [0, 1]
          #     trailing_stiffness = 0.5; # :            # 0.4      [0, 1]
          #     stiffness_insert_mode = 0.7; # :         # 0.5      [0, 1]
          #     trailing_stiffness_insert_mode = 0.7; # :# 0.5      [0, 1]
          #     damping = 0.8; # :                       # 0.65     [0, 1]
          #     damping_insert_mode = 0.8; # :           # 0.7      [0, 1]
          #     distance_stop_animating = 0.5; # :       # 0.1      > 0
          #   };
          # };
          lualine.enable = true;
          transparent = {
            enable = true;
            settings = {
              auto = true;
              groups = [

              ];
            };
          };
          web-devicons.enable = true;
          image.enable = true;
          nvim-autopairs.enable = true;
          nvim-surround.enable = true;
          trim = {
            enable = true;
            settings = {
              highlight = false;
            };
          };
          gitblame.enable = true;
          # hardtime.enable = true;
          none-ls = {
            enable = true;
            enableLspFormat = true;
            settings = {
              updateInInsert = false;
            };
            sources = {
            };
          };
          lsp-format.enable = true;
          conform-nvim = {
            enable = true;
            settings = {
              format_on_save = {
                lspFallback = true;
              };
              notify_on_error = true;
            };
          };
          /*
            lint = {
              enable = true;
              lintersByFt = {
                bash = [ "shellcheck" ];
                json = [ "jsonlint" ];
                markdown = [ "vale" ];
                go = [ "golangcilint" ];
                dockerfile = [ "hadolint" ];
                lua = [ "luacheck" ];
                nix = [ "deadnix" "nix" ] ++ lib.optionals (!config.plugins.lsp.servers.statix.enable) [ "statix" ];
                python = [ "pylint" ];
                sh = [ "shellcheck" ];
                yaml = [ "yamllint" ];
              };

              linters = {
                deadnix = {
                  cmd = lib.getExe pkgs.deadnix;
                };
                golangcilint = {
                  cmd = lib.getExe pkgs.golangci-lint;
                };
                jsonlint = {
                  cmd = lib.getExe pkgs.nodePackages.jsonlint;
                };
                luacheck = {
                  cmd = lib.getExe pkgs.luaPackages.luacheck;
                };
                # markdownlint = {
                #   cmd = lib.getExe pkgs.markdownlint-cli;
                # };
                pylint = {
                  cmd = lib.getExe pkgs.pylint;
                };
                shellcheck = {
                  cmd = lib.getExe pkgs.shellcheck;
                };
                statix = {
                  cmd = lib.getExe pkgs.statix;
                };
                yamllint = {
                  cmd = lib.getExe pkgs.yamllint;
                };
              };
            };
          */
          lsp = {
            enable = true;
            inlayHints = true;
            keymaps = {
              silent = true;
              diagnostic = {
                "<leader>dk" = {
                  action = "goto_prev";
                  desc = "[D]ebug up (Previous Diagnostic)";
                };
                "<leader>dj" = {
                  action = "goto_next";
                  desc = "[D]ebug down (Next Diagnostic)";
                };
                "<leader>do" = {
                  action = "open_float";
                  desc = "[D]ebug [O]pen (Open Line Diagnostics)";
                };
              };
              lspBuf = {
                gd = {
                  action = "definition";
                  desc = "[G]oto [Definition]";
                };
                gr = {
                  action = "references";
                  desc = "[G]oto [R]eferences";
                };
                gt = {
                  action = "type_definition";
                  desc = "[G]oto [T]ype";
                };
                gi = {
                  action = "implementation";
                  desc = "[G]oto [I]mplementation";
                };
                "<leader>re" = {
                  action = "rename";
                  desc = "[Re]name";
                };
              };
            };
            servers = {
              # More: https://nix-community.github.io/nixvim/plugins/lsp/servers/nimls/onAttach.html
              yamlls.enable = true; # yaml
              # Rust
              rust_analyzer = {
                enable = true;
                installRustc = true;
                installCargo = true;
              };
              ts_ls.enable = true; # TS/JS
              cssls.enable = true; # CSS
              tailwindcss.enable = true; # TailwindCSS
              html.enable = true; # HTML
              astro.enable = true; # AstroJS
              phpactor.enable = true; # PHP
              svelte.enable = false; # Svelte
              vuels.enable = false; # Vue
              pyright.enable = true; # Python
              nil_ls.enable = true; # Nix
              dockerls.enable = true; # Docker
              bashls.enable = true; # Bash
              clangd.enable = true; # C/C++
              csharp_ls.enable = true; # C#
              markdown_oxide.enable = true; # Markdown
            };
          };
          nix.enable = true;
          #TODO: noice for toolwindows?
          oil.enable = true; # TODO
          indent-blankline.enable = true;
          telescope = {
            enable = true;
            extensions = {
              fzf-native = {
                enable = true;
              };
            };
            settings.defaults = {
              vimgrep_arguments = [
                "${pkgs.ripgrep}/bin/rg"
                "-L"
                "--color=never"
                "--no-heading"
                "--with-filename"
                "--line-number"
                "--column"
                "--smart-case"
                "--fixed-strings"
              ];
              file_ignore_patterns = [
                "^.git/"
                "flake.lock"
              ];
              set_env.COLORTERM = "truecolor";
            };
          };
          treesitter = {
            enable = true;
            nixvimInjections = true;
            folding = false;
            settings = {
              indent.enable = true;
              # highlight.enable = true; #this caused random erros :(
            };
            grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
          };
          treesitter-refactor = {
            enable = true;
            highlightDefinitions = {
              enable = true;
              clearOnCursorMove = false;
            };
          };
          hmts.enable = true;
          trouble.enable = true;
          which-key.enable = true;
          #TODO: configure more dap
          dap.enable = true;
          dap-go.enable = true;
          dap-ui.enable = true;
          dap-virtual-text.enable = true;
          neotest = {
            enable = true;
            adapters.go.enable = true;
          };
        };

        clipboard = {
          register = "unnamedplus";
          providers.wl-copy.enable = true;
        };

        highlight.Todo = {
          # todo: replace with wallust scheme color
          fg = "Tomato";
          bg = "Yellow";
        };

        match.TODO = "TODO";

        opts = {
          updatetime = 100;

          relativenumber = true;
          number = true;

          hidden = true;
          mouse = "a";
          mousemodel = "extend";
          splitbelow = true;
          splitright = true;

          incsearch = true;
          inccommand = "split";
          ignorecase = true;
          smartcase = true;

          scrolloff = 8;

          termguicolors = true;

          tabstop = 4;
          shiftwidth = 4;
          expandtab = true;
          autoindent = true;

          wrap = false;

          undofile = true;
        };

        autoCmd = [
          {
            event = "InsertEnter";
            command = "norm zz";
          }
          {
            event = "VimEnter";
            command = ":TransparentEnable";
          }
        ];
      };

      # Setting session variables normally is broken when using home-manager ;(
      # context: https://github.com/nix-community/home-manager/issues/1011
      programs.bash = {
        enable = true;
        initExtra = ''
          export EDITOR="nvim"
          # wallust run ${toString ./wallpapers/wallhaven-zygxxo.jpg}
        '';
      };

      # home.file.".config/nvim" = {
      #     source = config.lib.file.mkOutOfStoreSymlink (runtimePath ./nvim);
      #     recursive = true;
      # };

      # Configure browsers

      programs.firefox.enable = true;
      programs.zen-browser = {
        enable = true;
        # any other options under `programs.firefox` are also supported here.
        # see `man home-configuration.nix`.
      };

      programs.kitty = {
        enable = true;
        settings = {
          background_opacity = 0.5;
        };
      };

      # workaround for making the config writable:
      # while this works... it is incredibly ugly :(
      # home.activation = {
      # run cp -RL "${config.xdg.configHome}/git" "${config.xdg.configHome}/git.contents"
      # run rm -rf "${config.xdg.configHome}/git"
      # run mv "${config.xdg.configHome}/git.contents" "${config.xdg.configHome}/git"
      # run chmod -R 755 "${config.xdg.configHome}/git"
      # replaceWithTarget = lib.hm.dag.entryAfter [ "writeBoundry" ] ''

      #   run cp -RL "${config.xdg.configHome}/todoist" "${config.xdg.configHome}/todoist.contents"
      #   run rm -rf "${config.xdg.configHome}/todoist"
      #   run mv "${config.xdg.configHome}/todoist.contents" "${config.xdg.configHome}/todoist"
      #   run chmod 755 "${config.xdg.configHome}/todoist"
      #   run chmod 600 "${config.xdg.configHome}/todoist/config.json"

      # '';
      # removeExisting = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      #   rm -rf "${config.xdg.configHome}/.config/git/config"
      # '';
      #
      # copy = let
      #   new = pkgs.writeText "tmp" (builtins.readFile ./);
      # in lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      #   rm -rf "/Users/me/.yabairc"
      #   cp "${newYabai}" "/Users/me/.yabairc"
      #   chmod +x "/Users/me/.yabairc"
      # '';
      # };

      # sops.secrets = {
      #   "oq-sshKeys-server" = {
      #     format = "binary";
      #     sopsFile = ./server/id_ed25519;

      #   };
      #   "oq-sshKeys-server-pub" = {
      #     format = "binary";
      #     sopsFile = ./server/id_ed25519.pub;
      #   };
      # };
      # home.activation."ssh-keys" = lib.hm.dag.entryAfter [ "writeBoundry" ] ''

      # '';

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      home.stateVersion = "25.05"; # Did you read the comment?
    };
}
