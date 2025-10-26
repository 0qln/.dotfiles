{
  pkgs,
  lib,
  ...
}: {
  programs.nixvim = {
    plugins = {
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
        inlayHints = false;
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
            package = pkgs.rust-analyzer; # use rust-analyzer from main channel
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
          # vuels.enable = false; # Vue (not supported anymore)
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
    };
  };
}
