# configuration for sops-nix utility
{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib; let
  inherit (config.utils) userRuntimeDir;
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  home.packages = with pkgs; [
    sops
    yubikey-manager
    age-plugin-yubikey
    pcsclite
  ];

  sops = {
    defaultSopsFormat = "yaml";
    # age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    age.keyFile = "${config.xdg.configHome}/sops/age/__all-keys.g.txt";
    defaultSymlinkPath = "${userRuntimeDir}/secrets";
    defaultSecretsMountPoint = "${userRuntimeDir}/secrets.d";
  };

  home.file.".config/sops/age/__all-keys.g.txt" = {
    text = builtins.readFile ../../../../yubis/yubi-1/age-yubikey-identity-ca0b293d.txt;
  };

  systemd.user.services."test-password-interactive" = let
    serviceUser = "test-pwd-user";
  in {
    Unit = {
      Description = "test systemd-ask-password";
    };
    Install = {
      WantedBy = ["sops-nix.service"];
    };
    Service = {
      # StandardOutput = "tty-force";
      # StandardInput = "tty";
      # TTYPath = "/dev/pts/3";
      # TTYReset = "yes";
      # TTYVHangup = "yes";
      ExecStart = "${pkgs.writeShellScript "test" ''
        PASSWORD="$(${pkgs.systemd}/bin/systemd-ask-password --no-tty 2>&1)"
        echo "password: $PASSWORD"
      ''}";
    };
  };

  # https://github.com/Mic92/sops-nix/issues/377#issuecomment-2980260975
  systemd.user.services.sops-nix = {
    Service = {
      ExecStartPre = [
        # Prevents this error on startup:
        # GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name org.freedesktop.Notifications was not provided by any .service files
        "${pkgs.writeShellScript "sops-nix-start-pre-wait-for-notifications" ''
          PIN=$(${pkgs.systemd}/bin/systemd-ask-password --no-tty "Enter YubiKey PIN:")
          echo "display: $DISPLAY"
          echo "authority: $XAUTHORITY"
          export AGE_YUBIKEY_PIN="$PIN"

          if [ -z "$(${getExe pkgs.yubikey-manager} list)" ]; then
            until ${pkgs.systemd}/bin/busctl --user list \
              | ${getExe pkgs.ripgrep} -q org.freedesktop.Notifications; do
              ${pkgs.coreutils}/bin/sleep 1
            done
          fi
        ''}"
        # Make sure to wait for the YubiKey insertion before starting the service
        "${pkgs.writeShellScript "sops-nix-start-pre" ''
          if [ -z "$(${getExe pkgs.yubikey-manager} list)" ]; then
            ${getExe pkgs.libnotify} --urgency=critical --wait 'SOPS-Nix' 'Insert YubiKey to mount secrets...'
            if [ -z "$(${getExe pkgs.yubikey-manager} list)" ]; then
              exit 1
            fi
          fi
        ''}"
      ];
      Environment = mkForce "DBUS_SESSION_BUS_ADDRESS=unix:path=%t/bus";

      Restart = "on-failure";
      RestartSec = "5s";
    };
    Unit = let
      deps = [
        "dbus-user-session.service"
        "graphical-session.target"
        "gpg-agent.socket"
        "pcscd.socket"
      ];
    in {
      Wants = deps;
      After = deps;
    };
  };
}
