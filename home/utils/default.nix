# Utils for home-manager modules.
{
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
  ];

  options.utils = mkOption {
    type = types.attrs;
  };

  config.utils = rec {
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
      matches = builtins.match "#([0-9a-f]{8})" color;
      val = builtins.elemAt matches 0;
    in "rgba(${val})";

    mkForceCopySecret = {
      secret, # can also contain a path e.g. todoist/todoist-token
      destPath, # Full destination path (e.g., "${config.xdg.configHome}/todoist/config.json")
      deps ? ["writeBoundary"],
    }:
      hm.dag.entryAfter deps
      # sh
      ''
        #!${pkgs.bash}/bin/bash
        dst="${destPath}"
        src="$XDG_RUNTIME_DIR/secrets/${secret}"
        if [[ -e "$dst" ]]; then
          run rm -r "$dst"
        fi
        # the todoist-cli cannot handle soft symlinks. hardlinks break
        # break because XDG_RUNTIME_DIR is usually /run/user/..., which is
        # an in-memory filesystem.
        # so we have no other option but to copy :(
        # (we could bind the file systems, but that's just overkill)
        run cp -Lrp "$src" "$dst"
      '';

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
        run cp -Lrp "$src" "$dst"
        chmod ${newMode} $dst
      '';

    userRuntimeDir = let
      name = config.home.username;
    in
      if (name == "root")
      then "/run"
      else "/run/user/${toString config.vars.user.uid}";
  };
}
