{pkgs, ...}: {
  programs.nixvim = {
    plugins = {
      telescope = {
        enable = true;
        extensions = {
          fzf-native = {
            enable = true;
          };
        };
        settings.defaults = {
          vimgrep_arguments = [
            "${pkgs.ripgrep}/bin/rg"
            "-L"
            "--color=never"
            "--no-heading"
            "--with-filename"
            "--line-number"
            "--column"
            "--smart-case"
            "--fixed-strings"
          ];
          file_ignore_patterns = [
            "^.git/"
            "flake.lock"
            "^result$"
          ];
          set_env.COLORTERM = "truecolor";
        };
      };
    };
  };
}
