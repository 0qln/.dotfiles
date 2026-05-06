{config, ...}: {
  format = "⟳";
  on-click = config.modules.hyprland.modules."rotate-screen".scripts.toggle;
  tooltip = true;
  tooltip-format = "Flip screen upside down.";
}
