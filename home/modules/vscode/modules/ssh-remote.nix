profile: {
  pkgs,
  config,
  lib,
  ...
}: let
  sshConfigFile = "/home/oq/.vscode/ssh.config";
in {
  programs.vscode.profiles.${profile} = {
    extensions = with pkgs.vscode-extensions; [
      ms-vscode-remote.remote-ssh
      ms-vscode.remote-explorer
    ];

    userSettings = {
      "remote.SSH.configFile" = sshConfigFile;
    };
  };

  home.activation.vscode-sshConfig = lib.mkIf config.modules.vscode.enable (
    config.utils.mkCopy {
      source = "/home/oq/.ssh/config";
      destPath = sshConfigFile;
      newMode = "600";
    }
  );
}
