{...}: {
  "format" = "{:%I:%M:%S %p} ";
  "interval" = 1;
  "tooltip-format" = "<tt>{calendar}</tt>";
  "calendar" = {
    "format" = {
      "today" = "<span color='#fAfBfC'><b>{}</b></span>";
    };
  };
  "actions" = {
    "on-click-right" = "shift_down";
    "on-click" = "shift_up";
  };
}
