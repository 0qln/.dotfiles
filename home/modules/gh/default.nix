{config, ...}: let
  hosts = "gh/hosts.yml";
  home = config.home.homeDirectory;
in {
  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };

  programs.gh-dash = {
    enable = true;
  };

  sops.secrets = {
    ${hosts} = {
      format = "yaml";
      sopsFile = ./secrets/hosts.yml;
      mode = "0600";
      key = "";
    };
  };

  systemd.user.tmpfiles.rules = [
    "L ${home}/.config/gh/hosts.yml - - - - ${config.sops.secrets.${hosts}.path}"
  ];
}
