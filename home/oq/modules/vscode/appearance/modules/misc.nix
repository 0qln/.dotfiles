profile:
{ pkgs, ... }:
{
  programs.vscode.profiles.${profile} = {

    userSettings = {
      "window.autoDetectHighContrast" = false;
      "debug.onTaskErrors" = "debugAnyway";
      "explorer.confirmDelete" = false;
    };

  };
}
