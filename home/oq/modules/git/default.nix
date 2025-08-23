{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git
    gh
  ];

  programs.git = {
    enable = true;
    userName = "0qln";
    userEmail = "linusnag@gmail.com";
  };

  programs.lazygit = {
    enable = true;
    settings = {
      #TODO: https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
    };
  };

}
