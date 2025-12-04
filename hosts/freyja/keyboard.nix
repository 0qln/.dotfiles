{...}: {
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "en";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "en";
}
