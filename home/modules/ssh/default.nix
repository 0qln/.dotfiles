{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.ssh;
in {
  options.modules.ssh = {
    enable = mkEnableOption "ssh config";
    enableWorkSimple = mkEnableOption "work simple stuff";
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = mkMerge [
        {
          "*" = {
            forwardAgent = false;
            addKeysToAgent = "no";
            compression = false;
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            hashKnownHosts = false;
            userKnownHostsFile = "~/.ssh/known_hosts";
            controlMaster = "no";
            controlPath = "~/.ssh/master-%r@%n:%p";
            controlPersist = "no";
          };
        }
        (let
          lifbrasirCfg = mkIf (builtins.hasAttr "server" config.modules.secrets.ssh.identities) {
            user = "root";
            identityFile = config.modules.secrets.ssh.identities.server;
            identitiesOnly = true;
            forwardAgent = true;
            addKeysToAgent = "yes";
          };
        in {
          "0qln.duckdns.org" = lifbrasirCfg;
          "07112025.xyz" = lifbrasirCfg;
        })
        (mkIf cfg.enableWorkSimple
          (let
            defaultCfg = {
              identityFile = config.modules.secrets.ssh.identities.work;
              user = "root";
              forwardAgent = true;
            };
          in {
            "kimai.unicorns.software" = defaultCfg;
            "nginx.unicorns.software" = defaultCfg;
            "odoo-dev.worksimple.de" = defaultCfg;
          }))
      ];
    };
  };
}
