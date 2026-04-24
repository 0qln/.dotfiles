{pkgs, ...}: {
  home.packages = with pkgs; [
    astyle
    jdt-language-server
  ];

  programs.nixvim = {
    plugins = {
      # this plugins also has nvim-dap integgration, which could be further configured.
      jdtls = {
        # enable = true;
        settings = {
          cmd = [
            "jdtls"
            "--jvm-arg=-javaagent:${pkgs.lombok}/share/java/lombok.jar"
            "--jvm-arg=-Xbootclasspath/a:${pkgs.lombok}/share/java/lombok.jar"
            "-data"
            {__raw = "vim.fn.getcwd()..'/.jdtls'";}
          ];

          settings.java = {
            eclipse = {
              downloadSources = true;
            };
            configuration = {
              updateBuildConfiguration = "interactive";
            };
            maven = {
              downloadSources = true;
            };
            implementationsCodeLens = {
              enabled = true;
            };
            referencesCodeLens = {
              enabled = true;
            };
          };
        };
      };
    };
  };
}
