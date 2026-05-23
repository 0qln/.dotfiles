profile: {
  pkgs,
  config,
  lib,
  ...
}: let
  sshConfigFile = "${config.home.homeDirectory}/.vscode/ssh.config";
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
      source = "${config.home.homeDirectory}/.ssh/config";
      destPath = sshConfigFile;
      newMode = "600";
    }
  );
}
