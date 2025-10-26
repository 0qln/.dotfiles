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

    opts = {
      # required by:
      # - colorizer
      termguicolors = true;
    };

    plugins.colorizer = {
      enable = true;
      settings = {
        user_default_options = {RRGGBBAA = true;};
      };
    };

    match.TODO = "TODO";
    highlight.Todo = {
      # todo: replace with wallust scheme color
      fg = "Tomato";
    };

    plugins = {
    };

    autoCmd = [
      {
        # TODO: sometimes does not work idk
        event = [
          "ColorScheme"
          "VimEnter"
        ];
        command = ":TransparentEnable";
      }
    ];

    # in case lualine is opaque again:
    # https://www.reddit.com/r/neovim/comments/s4ud1d/comment/hsvesja/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

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
    '';
  };
}
