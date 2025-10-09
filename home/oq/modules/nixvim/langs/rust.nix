{pkgs, ...}: {
  home.packages = with pkgs; [
    rustfmt
  ];

  programs.nixvim = {
    extraConfigLuaPost = ''
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

    autoCmd = [
      # auto run flychecks
      {
        event = [
          "InsertLeave"
          "TextChanged"
        ];
        pattern = ["*.rs"];
        callback = {
          __raw = ''
            function()
              vim.cmd.write {}

              -- ra_flycheck should work on it's own, but for some reason we have
              -- to save the buffer first, before we send the flycheck command the rust-analyzer.
              --
              -- https://neovim.io/doc/user/lsp.html#vim.lsp.util.make_text_document_params()
              -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocumentIdentifier
              -- https://users.rust-lang.org/t/rust-analyzer-run-clippy-on-demand/89293/2
              -- https://www.reddit.com/r/neovim/comments/1bszd7s/how_to_configure_manual_checks_with_rustanalyzer/
              --
              ra_flycheck()
            end
          '';
        };
      }
    ];
  };
}
