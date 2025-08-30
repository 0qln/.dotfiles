{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git
    gh
    delta
  ];

  programs.git = {
    enable = true;
    userName = "0qln";
    userEmail = "linusnag@gmail.com";
  };

  programs.lazygit = {
    enable = true;
    # https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
    settings = {
      # https://github.com/jesseduffield/lazygit/issues/155#issuecomment-2260986940
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --paging=never -s";
        };
      };
    };
  };

}
