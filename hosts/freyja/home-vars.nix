{
  lib,
  pkgs,
  ...
}: let
  # Sink names are stable, numeric ids are not, so resolve by pattern at
  # runtime. Exits non-zero if nothing matches, which shikane just logs.
  preferSink = pkgs.writeShellApplication {
    name = "audio-sink-prefer";
    runtimeInputs = [pkgs.pulseaudio];
    text = ''
      sink="$(pactl list sinks short | awk -v pat="$1" 'tolower($2) ~ tolower(pat) {print $2; exit}')"
      if [ -z "$sink" ]; then
        echo "audio-sink-prefer: no sink matching '$1'" >&2
        exit 1
      fi
      pactl set-default-sink "$sink"
    '';
  };
in {
  vars = {
    monitors = rec {
      devices = {
        center = {
          name = "eDP-1";
          dim = {
            s = 1.0;
            h = 1200;
            w = 1920;
          };
          workspaces = [1 2 3 4 5 6 7 8 9];
        };
      };

      arrangement = {
        byPictogram = "-";
      };
    };
  };

  modules.shikane = {
    enable = true;

    # Displays are matched on their EDID description rather than the port
    # name: `HDMI-A-1` moves around between reboots and ports, the description
    # does not. `%` is a substring match.
    #
    # A profile only applies if it describes *every* connected display and no
    # output is left over, so each combination needs its own entry. Anything
    # not covered here falls through to Hyprland's catch-all monitor rule.
    profiles = {
      builtin = {
        outputs = [
          {
            search = "d%BOE 0x0C68";
            mode = "1920x1200@60Hz";
            position = "0,0";
            scale = 1.0;
          }
        ];
      };

      docked-lg-tv = {
        outputs = [
          {
            search = "d%BOE 0x0C68";
            mode = "1920x1200@60Hz";
            position = "0,0";
            scale = 1.0;
          }
          {
            search = "d%LG TV";
            mode = "3840x2160@30Hz";
            position = "1920,0";
            scale = 1.0;
          }
        ];
        exec = [
          "${lib.getExe preferSink} hdmi"
        ];
      };
    };
  };
}
