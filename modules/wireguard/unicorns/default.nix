{config, ...}: let
  confName = config.private.wireguard.unicorns-name;
in {
  imports = [
    ../default.nix
  ];

  environment.shellAliases = {
    "unicorns-up" = "wg-quick up ${config.sops.secrets.${confName}.path}";
    "unicorns-down" = "wg-quick down ${config.sops.secrets.${confName}.path}";
  };
}
