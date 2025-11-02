{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.proton.vpn;
in {
  options.modules.proton.vpn = {
    enable = mkEnableOption "proton.vpn";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # this is depricated, TODO: find an alternative other than using gui
      # protonvpn-cli_2
    ];
  };
}
