{pkgs, ...}: {
  home.packages = with pkgs; [
    astyle
  ];

  programs.nixvim = {
    plugins = {
      lsp.servers.jdtls = {
        # Per-project workspace: inject -data via on_new_config since cmd only accepts strings.
        extraOptions.on_new_config = {
          __raw = ''
            function(new_config, new_root_dir)
              new_config.cmd = vim.list_extend(
                vim.deepcopy(new_config.cmd),
                {"-data", vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(new_root_dir, ":t")}
              )
            end
          '';
        };

        settings.java = {
          eclipse.downloadSources = true;
          configuration.updateBuildConfiguration = "interactive";
          maven.downloadSources = true;
          implementationsCodeLens.enabled = true;
          referencesCodeLens.enabled = true;
        };
      };

      # nvim-jdtls (disabled: using lsp.servers.jdtls instead; re-enable if richer Java features needed)
      # jdtls.enable = true;
    };
  };
}
