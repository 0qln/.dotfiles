profile:
{ pkgs, ... }:
{
  programs.vscode.profiles.${profile} = {
    userSettings = {
      #TODO: split this up
      "workbench.sideBar.location" = "right";
      "workbench.activityBar.location" = "top";
      "window.newWindowProfile" = "Default";
      "window.menuBarVisibility" = "compact";
      "gitlens.views.scm.grouped.views" = {
        "commits" = true;
        "branches" = true;
        "remotes" = true;
        "stashes" = true;
        "tags" = true;
        "worktrees" = true;
        "contributors" = true;
        "repositories" = false;
        "searchAndCompare" = true;
        "launchpad" = false;
      };
    };
  };
}
