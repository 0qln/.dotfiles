{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.dev;
in {
  options.modules.dev = {
    direnv.enable = mkEnableOption "direnv";
    devenv.enable = mkEnableOption "devenv";
    accessTokens.configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };

  config = {
    programs.direnv = mkIf cfg.direnv.enable {
      enable = true;
      nix-direnv.enable = true;
    };

    nix = mkMerge [
      (mkIf (cfg.accessTokens.configFile != null) {
        extraOptions = ''
          # include access tokens
          !include ${config.sops.secrets."nix/accessTokens".path}
        '';
      })
      (mkIf cfg.devenv.enable {
        extraOptions = ''
          # set up devenv-cachix
          extra-substituters = https://nixpkgs-python.cachix.org https://devenv.cachix.org
          extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU=
        '';
      })
    ];

    sops.secrets."nix/accessTokens" = mkIf (cfg.accessTokens.configFile != null) {
      mode = "0440";
      format = "binary";
      sopsFile = cfg.accessTokens.configFile;
    };

    home.packages = with pkgs;
      mkMerge [
        (mkIf cfg.devenv.enable [
          devenv
        ])
      ];
  };
}
