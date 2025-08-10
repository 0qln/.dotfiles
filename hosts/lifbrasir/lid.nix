{ ... }:
{
  # Don't turn off when laptop lid is closed.
  services.logind.lidSwitchExternalPower = "ignore";
}
