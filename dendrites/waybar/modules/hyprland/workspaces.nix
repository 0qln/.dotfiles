# https://github.com/Alexays/Waybar/wiki/Module:-Hyprland
{
  config,
  monitor,
  ...
}: {
  "format" = "{icon}";
  "format-icons" = {
    "active" = "";
    "default" = "";
    "empty" = "";
  };
  "persistent-workspaces" = {
    "*" = config.vars.monitors.devices.${monitor}.workspaces;
  };

  # todo:
  # - add a button where when clicked it adds a workspace
  # - when rightclicked on a workspace symbol, that workspace is closed.
}
