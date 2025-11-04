{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.ssh-service;
in {
  options.modules.ssh-service = {
    enable = mkEnableOption "ssh service";
    keys = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    users.extraUsers.root.openssh.authorizedKeys.keys = cfg.keys;

    networking.firewall.allowedTCPPorts = [22];
  };
}
