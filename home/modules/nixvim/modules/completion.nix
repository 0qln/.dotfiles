{pkgs, ...}: {
  programs.nixvim = {
    extraConfigLuaPost = ''
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

    # inspiration: https://github.com/dc-tec/nixvim/blob/main/config/plugins/cmp/cmp.nix
    plugins = {
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

      # bracket completion
      nvim-autopairs.enable = true;
    };
  };
}
