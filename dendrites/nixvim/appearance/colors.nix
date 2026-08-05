{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.nixvim.colors;
in {
  options.modules.nixvim.colors = {
    theme = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "the colorscheme";
    };
    highlight = {
      todo = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "Tomato";
        description = "whether to higlight 'todo'";
      };
      indent = mkOption {
        type = types.enum (builtins.readDir ./indents |> builtins.attrNames);
        default = "alternating.lua";
        example = "rainbow.lua";
        description = "indent color highlighting preset";
      };
    };
  };

  config = {
    programs.nixvim = mkMerge [
      (mkIf (cfg.highlight.todo != null) {
        match.TODO = "TODO";
        highlight.Todo = {
          fg = cfg.highlight.todo;
        };
      })
      {
        extraPlugins = with pkgs.vimPlugins; [
          everforest
          rose-pine
          tokyonight-nvim
          melange-nvim
          kanagawa-nvim
          (pkgs.vimUtils.buildVimPlugin {
            name = "mellifluous-nvim";
            src = pkgs.fetchFromGitHub {
              owner = "ramojus";
              repo = "mellifluous.nvim";
              rev = "4ce6258b31420aa4fd64b35b7f7cf42dffef7403";
              hash = "sha256-rtdDaANnzKqLNMXLcGDFnmzhU8IxjDPqw6Njp+uoZbI=";
            };
          })
          (pkgs.vimUtils.buildVimPlugin {
            name = "sora";
            src = pkgs.fetchFromGitHub {
              owner = "Aejkatappaja";
              repo = "sora";
              rev = "958f8f5c3c9790f1902c2c37f5c30e6fe36bab18";
              hash = "sha256-PKWVUp+loYijLLL6B9/jypRPBb0dx8r6KGs6rjS2iLo=";
            };
          })
          vim-moonfly-colors
          kanagawa-paper-nvim
          vague-nvim
          monokai-pro-nvim

          #TODO:
          # https://github.com/ramojus/mellifluous.nvim
          # https://github.com/dgox16/oldworld.nvim
          # https://github.com/everviolet/nvim
        ];

        colorscheme = mkIf (cfg.theme != null) cfg.theme;

        colorschemes = mkMerge [
          {
            moonfly.settings.transparent = config.modules.nixvim.transparency.enable;
          }
        ];

        opts = {
          # required by:
          # - colorizer
          # - bufferline
          termguicolors = true;
        };

        # https://github.com/catgoose/nvim-colorizer.lua
        plugins.colorizer = {
          enable = true;
          settings = {
            user_default_options = {
              css = true;
            };
          };
        };

        plugins = {
        };

        autoCmd = mkMerge [
          (mkIf config.modules.nixvim.transparency.enable [
            {
              # TODO: sometimes does not work idk
              event = [
                "ColorScheme"
                "VimEnter"
              ];
              command = ":TransparentEnable";
            }
          ])
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
          ${builtins.readFile ./indents/${cfg.highlight.indent}}
        '';
      }
    ];
  };
}
