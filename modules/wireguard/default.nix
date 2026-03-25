{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.wireguard;
in {
  options.modules.wireguard = {
    enable = mkEnableOption "wireguard";
  };

  config = mkIf cfg.enable {
    networking.wireguard = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      wireguard-tools
    ];

    environment.shellAliases = mkMerge [
      (let
        inherit (config.private.wireguard."unicorns") name enable;
      in
        mkIf enable {
          "unicorns-up" = "wg-quick up ${config.sops.secrets.${name}.path}";
          "unicorns-down" = "wg-quick down ${config.sops.secrets.${name}.path}";
        })
    ];
  };
}
