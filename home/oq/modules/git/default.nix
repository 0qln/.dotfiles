{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    git
    gh
    delta
  ];

  sops.secrets."work.config" = {
    sopsFile = ./work.config.secrets;
    format = "binary";
  };

  programs.git = {
    enable = true;
    userName = "0qln";
    userEmail = "linusnag@gmail.com";
    includes = [
      {
        condition = "gitdir:~/repos/work.devops/**";
        path = config.sops.secrets."work.config".path;
      }
    ];
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
