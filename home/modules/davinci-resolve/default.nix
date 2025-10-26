{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.davinci-resolve;
in {
  options.modules.davinci-resolve = {
    enable = mkEnableOption "davinci-resolve";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      davinci-resolve
    ];
  };
}
