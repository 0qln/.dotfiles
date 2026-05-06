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
}
