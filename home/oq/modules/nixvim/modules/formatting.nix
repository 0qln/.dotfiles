{
  pkgs,
  lib,
  ...
}: {
  options = with lib; {
    my-nixvim = {
      formatBufLua = mkOption {
        type = types.str;
        default =
          # lua
          ''require'conform'.format({ lsp_format = "fallback", async = true })'';
        description = "lua code to format a buffer";
      };
    };
  };
  config = {
    programs.nixvim = {
      plugins = {
        lsp-format.enable = true;
        indent-blankline = {
          enable = true;
          settings = {};
        };
        trim = {
          enable = true;
          settings = {
            highlight = false;
          };
        };
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
                "shfmt"
              ];
              rust = ["rustfmt"];
              cpp = ["clang_format"];
              nix = {
                __unkeyed-1 = "alejandra";
              };
              javascript = {
                __unkeyed-1 = "prettierd";
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
            formatters = {
              rustfmt = {
                command = lib.getExe pkgs.rustfmt;
              };
            };
          };
        };
      };
    };
  };
}
