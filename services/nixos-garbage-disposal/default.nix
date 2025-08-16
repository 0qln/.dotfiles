{
  onCalendar ? "Sun *-*-* 00:00:00",
  olderThan ? "14d",
}:
{ ... }:
let
  serviceName = "nixos-garbage-disposal";
in
{
  # https://nix.dev/manual/nix/2.18/command-ref/nix-collect-garbage#opt-delete-older-than
  systemd.services.${serviceName} = {
    wantedBy = [ "multi-user.target" ];
    description = "Garbage disposal for the nix/store";
    serviceConfig = {
      User = "root";
      Type = "exec";
      Environment = "PATH=/run/current-system/sw/bin";
    };
    script = ''
      nix-collect-garbage --delete-older-than ${olderThan}
    '';
  };

  systemd.timers.${serviceName} = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = onCalendar;
      Persistent = true;
      RandomizedDelaySec = "2h";
      Unit = "${serviceName}.service";
    };
  };
}
