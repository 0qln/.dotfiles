{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.devenv;
in {
  options.modules.devenv = {
    caches.enable = mkEnableOption "devenv caches";
  };

  config = {
    modules.nix.caches = mkIf cfg.caches.enable {
      "nixpkgs-python.cachix.org" = "hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU=";
      "devenv.cachix.org" = "w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    };
  };
}
