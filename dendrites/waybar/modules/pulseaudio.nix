{pkgs, ...}: {
  "max-volume" = 100;
  "scroll-step" = 10;
  "format" = "{icon}";
  "tooltip-format" = "{volume}%";
  "format-muted" = "×";
  "format-icons" = [
    " "
    " "
    " "
  ];
  "on-click" = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
}
