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
  };
}
