{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    todoist-electron
    todoist
  ];

  sops.secrets."todoist-token" = {
    format = "json";
    sopsFile = ./secrets.json;
    key = "";
    mode = "0600";
  };

  home.activation.todoist-token = config.utils.mkForceCopySecret {
    secret = "todoist-token";
    destPath = "${config.xdg.configHome}/todoist/config.json";
  };
}
