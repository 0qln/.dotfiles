profile: {pkgs, ...}: {
  programs.vscode.profiles.${profile} = {
    userSettings = {
      "gitlens.views.commitDetails.files.layout" = "tree";
      "explorer.confirmDragAndDrop" = false;
    };
  };
}
