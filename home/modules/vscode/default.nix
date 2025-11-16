{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.vscode;
in {
  imports = [
    #TODO: modulearize profiles.
    ./profiles/default.nix
    ./profiles/kimai.nix
    ./profiles/odoo.nix
    ./profiles/odoo.kanagawa.nix
    ./fixes/mutability.nix
  ];

  options.modules.vscode = {
    enable = mkEnableOption "vscode";
    package = mkOption {
      type = types.package;
      default = pkgs.vscode-fhs;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    programs.vscode = {
      enable = true;
      inherit (cfg) package;
    };
  };
}
