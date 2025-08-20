{ configFile }:
{ config, pkgs, ... }:
let
  name = "unicorns";
  confName = "wireguard/${name}.conf";
in
{
  imports = [
    ../default.nix
  ];

  sops.secrets.${confName} = {
    format = "binary";
    sopsFile = configFile;
    mode = "0400";
  };

  #todo: this does not work
  systemd.services."toggle-unicorns" = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "toggle-${name}" ''
        unicorns="${config.sops.secrets.${confName}.path}"
        echo "Toggle interface: $unicorns"
        if ip link show dev "${name}" > /dev/null 2>&1 ; then
          echo "Disconnecting from interface..."
          ${pkgs.wireguard-tools}/bin/wg-quick down "$unicorns"
        else
          echo "Connecting to interface..."
          ${pkgs.wireguard-tools}/bin/wg-quick up "$unicorns"
        fi
      ''}";
    };
  };
}
