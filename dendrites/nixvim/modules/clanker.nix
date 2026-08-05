{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.nixvim;
in {
  config = mkIf cfg.clanker.enable {
    programs.nixvim = {
      # copilot is unfree licensed
      # https://github.com/nix-community/nixvim/issues/2147#issuecomment-2747536904
      nixpkgs = {
        config = {
          allowUnfree = true;
        };
      };

      plugins = {
        copilot-lua = {
          enable = true;
          # https://nix-community.github.io/nixvim/plugins/copilot-lua/settings/index.html
          settings = {
            filetypes = {
              sh.__raw = ''
                function()
                  if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
                    -- disable for .env files
                    return false
                  end
                  return true
                end
              '';
            };
          };
        };

        copilot-lsp = {
          enable = true;
        };
      };
    };
  };
}
