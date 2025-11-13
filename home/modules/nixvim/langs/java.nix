{pkgs, ...}: {
  home.packages = with pkgs; [
    astyle
    jdt-language-server
  ];

  programs.nixvim = {
    plugins = {
      # this plugins also has nvim-dap integgration, which could be further configured.
      jdtls = {
        enable = true;
        settings = {
          cmd = [
            "jdtls"
            {__raw = "'-data='..vim.fn.getcwd()..\"/.jdtls\"";}
          ];
        };
      };
    };
  };
}
