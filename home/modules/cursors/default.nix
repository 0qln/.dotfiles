{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.cursor;

  # reference: https://haseebmajid.dev/posts/2023-10-08-how-to-create-systemd-services-in-nix-home-manager/
  reload-service = name: size: {
    Unit = {
      Description = "Reload the cursor.";
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      # We have to set the size to something that it wasn't previously first...
      # see: https://github.com/hyprwm/Hyprland/issues/6350
      ExecStart = "${pkgs.writeShellScript "reload-cursor" ''
        hyprctl setcursor "" 1
        hyprctl setcursor "${name}" ${toString size}
      ''}";
    };
  };

  isDir = _file: type: type == "directory";
  cursors = builtins.attrNames (attrsets.filterAttrs isDir (builtins.readDir ./cursors));
  cursorType = types.enum cursors;
in {
  options.modules.cursor = {
    enable = mkEnableOption "custom cursor";
    name = mkOption {
      type = types.str;
      description = "The name of the cursor to use";
    };
    cursor = mkOption {
      type = cursorType;
      description = "The cursor to use";
    };
    size = mkOption {
      type = types.nullOr types.int;
      default = 24;
      description = "The size of the cursor";
    };
  };

  config = mkIf cfg.enable (
    let
      cursor = import ./cursors/${cfg.cursor} {
        inherit pkgs;
        inherit cfg;
        inherit (config) utils;
      };
      isCustom = builtins.hasAttr "_customCursor" cursor && cursor._customCursor;
    in {
      # Both types of cursor have a size attribute.
      # Use the preferred size of each cursor package as the
      # default and let the user overwrite specify only
      # if he wants to change that default.
      modules.cursor.size = mkDefault cursor.size;

      systemd.user.services."reload-cursor" = reload-service cursor.name cfg.size;

      home = let
        customDef = {
          pointerCursor = cursor;
        };
        packagDef = {
          file.".icons/default".source = "${cursor.package}/share/icons/${cursor.name}";
        };
      in
        config.utils.mkIfElse isCustom customDef packagDef;
    }
  );
}
