{ pkgs, ... }:
let
  # reference: https://haseebmajid.dev/posts/2023-10-08-how-to-create-systemd-services-in-nix-home-manager/
  reload-service = name: size: {
    Unit = {
      Description = "Reload the cursor.";
    };
    Install = {
      WantedBy = [ "default.target" ];
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
in
{
  imports = [
    (import ./neco-arc { inherit reload-service; })
    # (import ./hatsune-miku-cursors { inherit reload-service; })
    ./oneko.nix
    ./dev.nix
  ];
}
