profile:
{ pkgs, ... }:
{

  programs.vscode.profiles.${profile} = {

    extensions = with pkgs.vscode-extensions; [
      jbockle.jbockle-format-files
    ];
  };

}
