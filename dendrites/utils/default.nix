{inputs, ...}:
with inputs.nixpkgs.lib; let
  utils = {
    mkIfElse = condition: yes: no:
      mkMerge [
        (mkIf condition yes)
        (mkIf (!condition) no)
      ];

    mkEnableOption = name: default:
      mkOption {
        type = types.bool;
        inherit default;
        description = "Whether to enable ${name}.";
        example = false;
      };
  };
in {
  flake.nixosModules.utils = {
    lib,
    config,
    ...
  }:
    with lib; let
      cfg = config.utils;
    in {
      options.utils = mkOption {
        type = lib.types.lazyAttrsOf lib.types.unspecified;
        description = "Utility functions.";
      };

      config.utils = mkMerge [
        utils

        {
          sanitizeHostName = name: builtins.replaceStrings ["."] ["-"] (lib.strings.sanitizeDerivationName name);

          mods = {
            # Wether a file is hidden or not.
            isHidden = file: (builtins.match "_.*" file) != null;

            # Whether a file is a flake parts module.
            isDendrite = file: (builtins.match ".*\?dendrite" file) != null;

            # Wether a file type is 'directory'.
            isDir = type: type == "directory";

            # If the module of filename/filetype is a module.
            isMod = f: t: (cfg.mods.isDir t) && !(cfg.mods.isHidden f) && !(cfg.mods.isDendrite f);

            # Collect all modules in a directory.
            collectMods = xDir: builtins.attrNames (lib.attrsets.filterAttrs cfg.mods.isMod (builtins.readDir xDir));

            # Idekanymore.
            eachX = with lib;
              xs: fns:
                map (i: i.fn i.x) (
                  attrsets.cartesianProduct {
                    x = xs;
                    fn = lists.flatten [fns];
                  }
                );
          };
        }
      ];
    };

  flake.homeModules.utils = {
    lib,
    pkgs,
    config,
    ...
  }:
    with lib; {
      imports = [
        ./sops.nix
        ./cursors.nix
        ./mutability.nix
        ./theme.nix
      ];

      options.utils = mkOption {
        type = types.attrs;
      };

      config.utils = mkMerge [
        utils
        rec {
          mkColorOption = name: default: let
            colorType = types.nullOr types.str;
          in
            mkOption {
              type = colorType;
              inherit default;
              description = "The color of ${name}";
              example = "#F7768EFF";
            };

          fmtColor_rgbaFn = color: let
            matches0 = builtins.match "#([0-9a-fA-F]{8})" color;
            matches1 = builtins.match "#([0-9a-fA-F]{6})" color;
            val =
              if matches0 != null
              then builtins.elemAt matches0 0
              else if matches1 != null
              then "${builtins.elemAt matches1 0}ff"
              else throw "`color` does not match the expected format.";
          in "rgba(${val})";

          fmtColorWithOpacity_rgbaFn = color: opacity: let
            matches0 = builtins.match "#([0-9a-fA-F]{6})" color;
            val =
              if matches0 != null
              then builtins.elemAt matches0 0
              else throw "`color` does not match the expected format.";
          in "rgba(${val}${opacity})";

          fmtMonitor_device = _k: device: pos: let
            w = toString device.dim.w;
            h = toString device.dim.h;
            s = toString device.dim.s;
            x = toString pos.x;
            y = toString pos.y;
            r = toString pos.r;
            hz = toString device.hz;
            inherit (device) name;
          in "${name}, ${w}x${h}@${hz}Hz, ${x}x${y}, ${s}, transform, ${r}";

          # fmtOpacity_percentage = opacity: let

          # Float to Int
          ftoi = x: builtins.floor x;

          # Float to Percentage
          ftop = x: x * 100;

          # some services (e.g. the todoist-cli) cannot handle soft symlinks.
          # hardlinks break break because XDG_RUNTIME_DIR is usually /run/user/...,
          # which is an in-memory filesystem.
          # so we have no other option but to copy :(
          # (we could bind the file systems, but that's just overkill)
          mkForceCopySecret = {
            secret, # can also contain a path e.g. todoist/todoist-token
            destPath, # Full destination path (e.g., "${config.xdg.configHome}/todoist/config.json")
          }: {
            Unit = {
              Description = "Copy secret ${secret} to ${destPath}.";
              After = ["sops-nix.service"];
            };

            Service = {
              Environment = "PATH=${pkgs.coreutils}/bin";
              ExecStart = "${pkgs.writeShellScript "copy-secret" ''
                set -euo pipefail

                # $XDG_RUNTIME_DIR is not available in some contexts, so we hardcode this here.
                src="${userRuntimeDir}/secrets/${secret}"
                dst="${destPath}"

                echo "dst=$dst"
                echo "src=$src"

                if [[ -e "$dst" ]]; then
                  echo "Destination exists. Removing..."
                  rm -fr "$dst"
                fi

                echo "Copying secret..."
                mkdir -p "$(dirname "$dst")"
                cp -Lrp "$src" "$dst"

                if [[ -f "$dst" ]]; then
                  echo "Done."
                  exit 0
                else
                  echo "ERROR: Failed to copy secret!"
                  exit 1
                fi
              ''}";
            };

            Install = {
              WantedBy = ["default.target"];
            };
          };

          mkCopy = {
            source,
            destPath, # Full destination path (e.g., "${config.xdg.configHome}/todoist/config.json")
            newMode ? "700",
            deps ? ["writeBoundary"],
          }:
            hm.dag.entryAfter deps
            #sh
            ''
              #!${pkgs.bash}/bin/bash
              dst="${destPath}"
              src="${source}"
              if [[ -e "$dst" ]]; then
                run rm -r "$dst"
              fi
              run mkdir -p "$(dirname "$dst")"
              run cp -Lrp "$src" "$dst"
              run chmod ${newMode} $dst
            '';

          userRuntimeDir = let
            name = config.home.username;
          in
            if (name == "root")
            then "/run"
            else "/run/user/${toString config.vars.user.uid}";

          # credits: https://github.com/nix-community/nur-combined/blob/main/repos/rycee/pkgs/firefox-addons/default.nix
          buildFirefoxXpiAddon = lib.makeOverridable (
            {
              stdenv ? pkgs.stdenv,
              fetchurl ? pkgs.fetchurl,
              pname,
              version,
              addonId,
              url ? "",
              urls ? [], # Alternative for 'url' a list of URLs to try in specified order.
              sha256,
              meta,
              ...
            }:
              stdenv.mkDerivation {
                name = "${pname}-${version}";

                inherit meta;

                src = fetchurl {inherit url urls sha256;};

                preferLocalBuild = true;
                allowSubstitutes = true;

                passthru = {
                  inherit addonId;
                };

                buildCommand = ''
                  dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
                  mkdir -p "$dst"
                  install -v -m644 "$src" "$dst/${addonId}.xpi"
                '';
              }
          );
        }
      ];
    };
}
