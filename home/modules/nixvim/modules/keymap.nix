{config, ...}: let
  cfg = config.modules.nixvim;
in {
  programs.nixvim = {
    plugins = {
      # key = "ysawb"
      nvim-surround.enable = true;

      # key = "gc/gcc"
      commentary.enable = true;

      # folding
      ufo.enable = true;
    };
    keymaps = [
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
        action = "<cmd>lua ${cfg.formatting.formatBufLua}<CR>";
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

      # [v]iew related maps
      {
        key = "<leader>vw";
        action.__raw = ''
          function()
            vim.opt.wrap = not vim.opt.wrap:get()
          end
        '';
        options = {
          desc = "[V]view > [w]rap (Toggle local line wrapping)";
        };
      }
    ];
  };
}
