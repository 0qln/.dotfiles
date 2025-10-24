{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.tools;
in {
  options.modules.tools = {
    enable = mkEnableOption "tools";
    qimgv = {
      setDefault = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Set as default app for these";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # files
      fzf
      fd
      tree
      unzip
      ripgrep
      srm

      # images/videos
      ffmpeg
      mpv
      imagemagick
      qimgv
      vlc

      # networking
      iperf3
      nethogs

      # super important
      fastfetch
    ];

    xdg.mimeApps.defaultApplications = builtins.listToAttrs (
      map (type: {
        name = type;
        value = "qimgv.desktop";
      })
      cfg.qimgv.setDefault
    );
  };
}
