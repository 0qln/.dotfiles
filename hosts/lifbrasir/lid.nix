{...}: {
  # Don't turn off when laptop lid is closed.
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
}
