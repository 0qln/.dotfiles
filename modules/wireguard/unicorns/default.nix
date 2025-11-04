{config, ...}: let
  confName = config.private.wireguard.unicorns-name;
in {
  environment.shellAliases = {
    "unicorns-up" = "wg-quick up ${config.sops.secrets.${confName}.path}";
    "unicorns-down" = "wg-quick down ${config.sops.secrets.${confName}.path}";
  };
}
