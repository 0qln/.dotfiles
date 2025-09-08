{config, ...}: {
  imports = [
    ./default.nix
  ];

  sops.secrets."work.config" = {
    sopsFile = ./work.config.secrets;
    format = "binary";
  };

  programs.git = {
    includes = [
      {
        condition = "gitdir:~/repos/work.devops/**";
        path = config.sops.secrets."work.config".path;
      }
    ];
  };
}
