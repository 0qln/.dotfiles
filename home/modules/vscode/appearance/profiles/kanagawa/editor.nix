profile: {...}: {
  programs.vscode.profiles.${profile} = {
    userSettings = {
      "editor.minimap.enabled" = false;
      "workbench.editor.enablePreview" = false;
    };
  };
}
