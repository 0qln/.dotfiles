{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.spotify;
in {
  options.modules.spotify = {
    enable = mkEnableOption "spotify";
    premium.enable = config.utils.mkEnableOption "some of the premium features" true;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (
        spotify.overrideAttrs (oldAttrs: let
          spotx = fetchurl {
            url = "https://raw.githubusercontent.com/SpotX-Official/SpotX-Bash/main/spotx.sh";
            hash = "sha256-sx9TzfJdPJqIRzIpzcpfHxXsQ1uJWTeTLs6bIq78HL4=";
          };
        in {
          nativeBuildInputs =
            (oldAttrs.nativeBuildInputs or [])
            ++ [
              perl
              unzip
              zip
            ];

          postInstall =
            (oldAttrs.postInstall or "")
            + ''
              bash ${spotx} -f -P "$out/share/spotify" -B --premium
              rm -f "$out/share/spotify/"*.bak
            '';
        })
      )

      # tray
      spotify-tray
    ];

    # not crackable :(
    services.spotifyd = {
      enable = true;
      settings = {};
      package = pkgs.spotifyd.override {
        # withKeyring = config.modules.pam.enable;
      };
    };
  };
}
