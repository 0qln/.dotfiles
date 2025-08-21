profile:
{ pkgs, ... }:
{

  programs.vscode.profiles.${profile} = {

    extensions = with pkgs.vscode-extensions; [
      ms-vscode-remote.remote-ssh
      ms-vscode.remote-explorer
    ];
  };

}
