{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.splatmoji;
  splatmoji = pkgs.stdenv.mkDerivation rec {
    pname = "splatmoji";

    version = "v1.2.0";

    src = pkgs.fetchFromGitHub {
      owner = "cspeterson";
      repo = "splatmoji";
      rev = version;
      hash = "sha256-fsZ8FhLP3vAalRJWUEi/0fe0DlwAz5zZeRZqAuwgv/U=";
    };

    buildPhase = ''
      :
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp -R ./* $out/bin
    '';
  };
in {
  options.modules.splatmoji = {
    enable = config.utils.mkEnableOption "splatmoji" config.modules.rofi.enable;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        xsel
        jq
      ]
      ++ [
        splatmoji
      ];

    home.file.".config/splatmoji/splatmoji.config" = {
      text = ''
        xsel_command=wl-copy
        paste_command=wl-paste
        xdotool_command=YDOTOOL_SOCKET=/run/ydotoold/socket ydotool type
      '';
    };
  };
}
