{
  flakeDir,
  mode ? "rebuild",
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

  # does not work with submodules

  programs.git = {
    enable = true;
    config = {
      safe.directory = [
        flakeDir
      ];
    };
  };

  systemd.services.${serviceName} = {
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
      git fetch && git pull && git add .
      nix flake update
      nixos-rebuild ${mode} --flake ${flakeDir}?submodules=0#${host-name} --max-jobs 1
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
