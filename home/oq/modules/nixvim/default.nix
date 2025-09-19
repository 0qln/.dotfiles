{
  pkgs,
  lib,
  config,
  inputs,
  osConfig,
  ...
}: {
  # just in case i want to do it via copying my lua config again:
  # - https://github.com/Kidsan/nixos-config/blob/main/home/programs/neovim/nvim/lua/kidsan/set.lua
  # - https://github.com/samiulbasirfahim/flakes/blob/main/home/rxen/neovim/config/init.lua
  # - my example in utils.nix file.

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

  imports = [
    inputs.nixvim.homeModules.nixvim
    ./colors.nix
  ];

  home.packages = with pkgs; [
    deadnix
    golangci-lint
    nodePackages.jsonlint
    luaPackages.luacheck
    pylint
    shellcheck
    statix
    yamllint
    alejandra
    # vale-ls
  ];

  programs.nixvim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

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
      # improved > <
      {
        action = ">gv";
        key = ">";
        mode = ["v"];
      }
      {
        action = "<gv";
        key = "<";
        mode = ["v"];
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
        action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
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
        action = "<cmd>lua vim.lsp.buf.format()<CR>";
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
        action = "<cmd>lua vim.lsp.buf.definition()<CR>";
        key = "gd";
        options = {
          silent = true;
          noremap = true;
          desc = "Go to definition";
        };
      }
      # Go to references
      {
        action = "<cmd>lua vim.lsp.buf.references()<CR>";
        key = "gr";
        options = {
          silent = true;
          noremap = true;
          desc = "Go to references";
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
      # Telescope search (live grep)
      {
        action = "<cmd>Telescope live_grep<CR>";
        key = "<leader>/";
        options = {
          silent = true;
          noremap = true;
          desc = "Search grep";
        };
      }
      # Telescope search buffers
      {
        action = "<cmd>Telescope buffers<CR>";
        key = "<leader>sb";
        options = {
          silent = true;
          noremap = true;
          desc = "Search buffers";
        };
      }
      # Telescope search commands
      {
        action = "<cmd>Telescope command_history<CR>";
        key = "<leader>sc";
        options = {
          silent = true;
          noremap = true;
          desc = "Search commands";
        };
      }
      # Telescope search files
      {
        action = "<cmd>Telescope find_files<CR>";
        key = "<leader><leader>";
        options = {
          silent = true;
          noremap = true;
          desc = "Search files";
        };
      }
      # Telescope quickfixlist
      {
        action = "<cmd>Telescope quickfix<CR>";
        key = "<leader>ql";
        options = {
          silent = true;
          noremap = true;
          desc = "Quickfix list";
        };
      }
      # Telescope undo tree
      {
        action = "<cmd>UndotreeToggle<CR>";
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
        action = "<cmd>vsplit<CR>";
        key = "<leader>v";
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
        action = "<cmd>Trouble diagnostics toggle<CR>";
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
        action = "<cmd>DapToggleBreakpoint<CR>";
        options = {
          silent = true;
          noremap = true;
          desc = "Toggle breakpoint";
        };
      }
      {
        key = "<leader>dB";
        action = "<cmd>DapClearBreakpoints<CR>";
        options = {
          silent = true;
          noremap = true;
          desc = "Clear all breakpoints";
        };
      }
      {
        key = "<leader>dc";
        action = "<cmd>DapContinue<CR>";
        options = {
          silent = true;
          noremap = true;
          desc = "Start/Continue debugging";
        };
      }
      {
        key = "<leader>dso";
        action = "<cmd>DapStepOver<CR>";
        options = {
          silent = true;
          noremap = true;
          desc = "Step over";
        };
      }
      {
        key = "<leader>dsi";
        action = "<cmd>DapStepInto<CR>";
        options = {
          silent = true;
          noremap = true;
          desc = "Step into";
        };
      }
      {
        key = "<leader>dsO";
        action = "<cmd>DapStepOut<CR>";
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
        key = "<leader>st";
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
      {
        key = "j";
        action = "gj";
      }
      {
        key = "k";
        action = "gk";
      }
      {
        key = "<leader>dr";
        action = "<cmd>lua ra_flycheck()<CR>";
        options = {
          desc = "[D]iagnostics [R]un (Run rust flycheck)";
        };
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

      -- tab indent colors
      -- #TODO: make work with half-opaque colors
      local highlight = {
          "CursorColumn",
          "Whitespace",
      }
      require("ibl").setup {
          indent = { highlight = highlight, char = "" },
          whitespace = {
              highlight = highlight,
              remove_blankline_trail = false,
          },
          scope = { enabled = false },
      }

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

      -- rust_analyzer flycheck
      function ra_flycheck()
        local clients = vim.lsp.get_clients({
          name = 'rust_analyzer',
        })
        for _, client in ipairs(clients) do
          local params = vim.lsp.util.make_text_document_params()
          client.notify('rust-analyzer/runFlycheck', params)
        end
      end
    '';

    # in case lualine is opaque again:
    #https://www.reddit.com/r/neovim/comments/s4ud1d/comment/hsvesja/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

    # cmp

    plugins = {
      vimtex = {
        enable = true;
        settings = {
          compiler_method = "generic";
          compiler_generic = let
            compiler = pkgs.writeShellScriptBin "latex-compiler" ''

              if [ -f "@tex" ]; then
                file="@tex"
              else
                file="main.tex"
              fi
              echo "Compiling tex file: $file"

              # latexmk integration docs: https://github.com/lervag/vimtex/blob/master/doc/vimtex.txt#L1019
              cmd_latex="latexmk -verbose \
                -file-line-error \
                -synctex=1 \
                -interaction=nonstopmode \
                -pvc \
                '$file' "

              cmd="$cmd_latex"

              echo "Executing: $cmd"

              if [ -f shell.nix ]; then
                shell="shell.nix"
                echo "Using shell: $shell"
                nix-shell "$shell" --command "$cmd"
              else
                exec "$cmd"
              fi
            '';
          in {
            command = ''${compiler}/bin/latex-compiler'';
          };
          view_method = "zathura";
          syntax_conceal = {
            "accents" = 1;
            "ligatures" = 1;
            "cites" = 1;
            "fancy" = 1;
            "spacing" = 1;
            "greek" = 1;
            "math_bounds" = 1;
            "math_delimiters" = 1;
            "math_fracs" = 1;
            "math_super_sub" = 1;
            "math_symbols" = 1;
            "sections" = 1;
            "styles" = 1;
          };
        };
      };

      tmux-navigator.enable = true;

      lazygit = {
        enable = true;
      };

      # does not work: https://github.com/amitds1997/remote-nvim.nvim/issues/203
      remote-nvim = {
        enable = true;
        settings = {
        };
      };

      # inspiration: https://github.com/dc-tec/nixvim/blob/main/config/plugins/cmp/cmp.nix

      cmp-emoji.enable = true;
      # cmp_luasnip.enable = true;
      cmp-cmdline.enable = true;
      cmp-buffer.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-async-path.enable = true;

      schemastore = {
        enable = true;
        yaml.enable = true;
        json.enable = false;
      };

      cmp-nvim-ultisnips = {
        # enable = true;
        # settings = {
        # };
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
            {name = "nvim_lsp";}
            {name = "cmp_lsp_rs";}
            # go-lang: go_deep
            {name = "nvim_lsp_signature_help";}
            {name = "nvim_lsp_document_symbol";}
            {name = "diag-codes";}
            {name = "async_path";}
            {name = "buffer";}
            {name = "luasnip";}
            # {name = "ultisnips";}
            #TODO: https://github.com/lukas-reineke/cmp-rg?tab=readme-ov-file
            #TODO: https://github.com/tzachar/cmp-ai
            {name = "emoji";}
            {name = "cmdline";}
            # { name = "cmp-tw2css"; } # TODO: cmp-tw2css does not exist on nixvim?
            {name = "latex_symbols";}
          ];
          snippet = {
            expand = "luasnip";
            # expand = "ultisnips";
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
            "<tab>" = "cmp.mapping.confirm({ select = false })";
            "<S-enter>" = "cmp.mapping.confirm({ select = true })";
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
      # image.enable = true;
      nvim-autopairs.enable = true;
      nvim-surround.enable = true;
      trim = {
        enable = true;
        settings = {
          highlight = false;
        };
      };
      gitblame.enable = true;
      # none-ls = {
      #   enable = true;
      #   # enableLspFormat = true; # default is: plugins.lsp-format.enable
      #   settings = {
      #     updateInInsert = false;
      #   };
      #   sources = {
      #     code_actions = {
      #       gitsigns.enable = true;
      #       statix.enable = true;
      #     };
      #     diagnostics = {
      #       statix.enable = true;
      #       yamllint.enable = true;
      #     };
      #     formatting = {
      #       nixfmt = {
      #         enable = true;
      #         package = pkgs.nixfmt-rfc-style;
      #       };
      #       black = {
      #         enable = true;
      #         settings = ''
      #           {
      #             extra_args = { "--fast" },
      #           }
      #         '';
      #       };
      #       prettier = {
      #         enable = true;
      #         # disableTsServerFormatter = true;
      #         settings = ''
      #           {
      #             extra_args = { "--no-semi" },
      #           }
      #         '';
      #       };
      #       stylua.enable = true;
      #       yamlfmt = {
      #         enable = true;
      #       };
      #       hclfmt.enable = true;
      #     };
      #   };
      # };
      lsp-format.enable = true;
      conform-nvim = {
        enable = true;
        settings = {
          # formatters: https://github.com/stevearc/conform.nvim?tab=readme-ov-file#formatters
          format_on_save = {
            lspFallback = true;
          };
          notify_on_error = true;
          formatters_by_ft = {
            bash = [
              "shellcheck"
              "shellharden"
              "shfmt"
            ];
            cpp = ["clang_format"];
            nix = {
              __unkeyed-1 = "alejandra";
            };
            javascript = {
              __unkeyed-1 = "prettierd";
              __unkeyed-2 = "prettier";
              timeout_ms = 2000;
              stop_after_first = true;
            };
            latex = ["latexindent"];
            "_" = [
              "squeeze_blanks"
              "trim_whitespace"
              "trim_newlines"
            ];
          };
        };
      };
      lint = {
        enable = true;
        lintersByFt = {
          bash = ["shellcheck"];
          json = ["jsonlint"];
          # markdown = ["vale"];
          go = ["golangcilint"];
          dockerfile = ["hadolint"];
          lua = ["luacheck"];
          nix = [
            "deadnix"
            "nix"
            "statix"
          ];
          python = ["pylint"];
          sh = ["shellcheck"];
          yaml = ["yamllint"];
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
          # vale = { # exits with code 2 fsr
          #   cmd = lib.getExe pkgs.vale-ls;
          # };
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
              desc = "[D]iagnostics [O]pen (Open Line Diagnostics)";
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
            package = pkgs.rust-analyzer; #use rust-analyzer from main channel
            installRustc = false;
            installCargo = false;
            settings = {
              checkOnSave = true;
            };
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
          texlab.enable = true; # latex
        };
      };
      nix.enable = true;
      #TODO: noice for toolwindows?
      oil.enable = true;
      indent-blankline = {
        enable = true;
        settings = {};
      };
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
      dap-ui.enable = true;
      dap-virtual-text.enable = true;
      neotest = {
        enable = true;
        adapters.go.enable = true;
      };
    };

    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = osConfig.services.displayManager.sddm.wayland.enable;
    };

    highlight.Todo = {
      # todo: replace with wallust scheme color
      fg = "Tomato";
    };

    match.TODO = "TODO";

    diagnostic.settings = {
      update_in_insert = false;
    };

    opts = {
      conceallevel = 1;

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
        event = ["InsertLeave" "TextChanged"];
        pattern = ["*.rs"];
        callback = {
          __raw = ''
            function()
              vim.cmd.write {}

              -- This should work, but for some reason we have to save the buffer first,
              -- before we send the flycheck command the rust-analyzer.
              --
              -- https://neovim.io/doc/user/lsp.html#vim.lsp.util.make_text_document_params()
              -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocumentIdentifier
              -- https://users.rust-lang.org/t/rust-analyzer-run-clippy-on-demand/89293/2
              -- https://www.reddit.com/r/neovim/comments/1bszd7s/how_to_configure_manual_checks_with_rustanalyzer/
              --
              -- ra_flycheck()
            end
          '';
        };
      }
    ];

    extraConfigVim = ''
      augroup WrapLinePerFT
          autocmd!
          autocmd FileType tex setlocal wrap
          autocmd FileType md setlocal wrap
      augroup END
    '';
  };
}
