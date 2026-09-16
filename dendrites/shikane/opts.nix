{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.homeModules.shikane-opts = {...}: {
    options.modules.shikane = let
      outputType = types.submodule {
        options = {
          search = mkOption {
            type = types.either types.str (types.listOf types.str);
            description = ''
              shikane search pattern(s) of the form `[[attrs]kind]pattern`.

              `attrs` is a sequence of letters from {d,n,m,v,s} (description,
              name, model, vendor, serialnumber), highest weight first.
              `kind` is one of `=` (full text), `%` (substring), `/` (regex).

              Prefer matching on vendor/model/serial over the port name:
              names like `HDMI-A-1` are not stable across reboots or ports.
            '';
            example = "vm=BOE 0x0C68";
          };

          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to enable the matched display.";
          };

          mode = mkOption {
            type = types.nullOr types.str;
            default = "preferred";
            description = ''
              `preferred`, `best`, or `<width>x<height>[@<rate>[Hz]]`.
              Prefix with `!` to send the values to the compositor verbatim
              instead of matching against the advertised modes.

              A display is only matched if it actually supports this mode, so
              an over-specific mode here will silently disable the profile.
            '';
            example = "1920x1200@60Hz";
          };

          position = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Position in the global coordinate space, `x,y`.";
            example = "1920,0";
          };

          scale = mkOption {
            type = types.nullOr types.float;
            default = null;
            description = "Scaling factor. Null leaves the scale untouched.";
          };

          transform = mkOption {
            type = types.nullOr (types.enum [
              "normal"
              "90"
              "180"
              "270"
              "flipped"
              "flipped-90"
              "flipped-180"
              "flipped-270"
            ]);
            default = null;
            description = "Display rotation/flip. Null leaves it untouched.";
          };

          adaptiveSync = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = "Variable refresh rate (VRR).";
          };

          exec = mkOption {
            type = types.listOf types.str;
            default = [];
            description = ''
              Commands run after this output was configured.
              `$SHIKANE_OUTPUT_NAME` holds the display name.
              Execution order is not guaranteed.
            '';
          };
        };
      };

      profileType = types.submodule {
        options = {
          outputs = mkOption {
            type = types.listOf outputType;
            description = ''
              The displays this profile describes.

              A profile is only considered if *every* connected display matches
              at least one output AND no output is left unmatched, so each
              profile must describe a complete physical setup.
            '';
          };

          exec = mkOption {
            type = types.listOf types.str;
            default = [];
            description = ''
              Commands run after the profile was applied successfully.
              `$SHIKANE_PROFILE_NAME` holds the profile name.
              Execution order is not guaranteed.
            '';
          };
        };
      };
    in {
      enable = mkEnableOption "shikane, dynamic display hotplug configuration";

      timeout = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Milliseconds to wait after a display change is detected.
          Usually leave this null; it only slows shikane down.
        '';
      };

      profiles = mkOption {
        type = types.attrsOf profileType;
        default = {};
        description = ''
          Display setups, keyed by profile name.

          Capture a new one by arranging the displays however you like and
          running `monitors-capture <name>`, then paste the result here.
        '';
      };
    };
  };
}
