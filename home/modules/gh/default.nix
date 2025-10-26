{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.gh;
  hosts = "gh/hosts.yml";
  home = config.home.homeDirectory;
in {
  options.modules.gh = {
    enable = mkEnableOption "github cli";
    hostsYmlFile = mkOption {
      type = types.nullOr types.path;
      description = "hosts.yml config file path";
    };
  };

  config = mkIf cfg.enable {
    programs.gh = {
      enable = true;
      gitCredentialHelper = {
        enable = true;
      };
    };

    programs.gh-dash = {
      enable = true;
    };

    sops.secrets = mkIf (cfg.hostsYmlFile != null) {
      ${hosts} = {
        format = "yaml";
        sopsFile = cfg.hostsYmlFile;
        mode = "0600";
        key = "";
      };
    };

    systemd.user.tmpfiles.rules = mkIf (cfg.hostsYmlFile != null) [
      "L ${home}/.config/gh/hosts.yml - - - - ${config.sops.secrets.${hosts}.path}"
    ];
  };
}
