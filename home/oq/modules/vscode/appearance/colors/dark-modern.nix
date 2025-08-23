profile:
{ pkgs, ... }:
{
  programs.vscode.profiles.${profile} = {

    userSettings = {
      "workbench.colorTheme" = "Dark Modern";
    };

  };
}
