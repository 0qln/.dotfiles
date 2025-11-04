{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.repos;
in {
  options.modules.repos = {
    enable = mkEnableOption "default repos directory structre with nix shells";
  };

  config = mkIf cfg.enable {
    home.file."repos/work.devops/.envrc".text =
      # bash
      ''
        use nix
      '';

    home.file."repos/work.devops/shell.nix" = {
      source = ./work.devops/shell.nix;
    };
  };
}
