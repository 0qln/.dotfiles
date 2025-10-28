{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.ssh;
in {
  imports = [
    ./defaultConfig.nix
  ];

  options.modules.ssh = {
    enable = mkEnableOption "ssh config";
    enableWorkSimple = mkEnableOption "work simple stuff";
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      matchBlocks = mkMerge [
        {
          "0qln.duckdns.org" = {
            user = "root";
            identityFile = config.modules.secrets.ssh.identities.server;
            identitiesOnly = true;
            addKeysToAgent = "yes";
          };
        }
        (mkIf cfg.enableWorkSimple
          (let
            defaultCfg = {
              identityFile = config.modules.secrets.ssh.identities.work;
              user = "root";
              forwardAgent = true;
            };
          in {
            "kimai.unicorns.software" = defaultCfg;
            "odoo-dev.worksimple.de" = defaultCfg;
          }))
      ];
    };
  };
}
