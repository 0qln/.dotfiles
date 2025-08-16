{
  flakeDir,
  mode ? "rebuild",
  gitUser ? "oq",
  onCalendar ? "Sat *-*-* 00:00:00",
}:
{ pkgs, host-name, ... }:
let
  serviceName = "flake-upgrader";
in
{
  environment.systemPackages = with pkgs; [
    shadow
  ];

  systemd.services.${serviceName} = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    description = "Flake update and build the system.";
    serviceConfig = {
      User = "root";
      Type = "exec";
      Environment = "PATH=${pkgs.lib.makeBinPath [ pkgs.shadow ]}:/run/current-system/sw/bin";
    };
    script = ''
      #!${pkgs.bash}/bin/sh
      cd ${flakeDir}
      su ${gitUser} -c "git fetch && git pull && git add . "
      su ${gitUser} -c "nix flake update"
      nixos-rebuild ${mode} --flake ${flakeDir}?submodules=1#${host-name} --max-jobs 1
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
