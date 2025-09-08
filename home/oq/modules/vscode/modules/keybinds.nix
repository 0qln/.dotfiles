profile: {pkgs, ...}: {
  programs.vscode.profiles.${profile} = {
    keybindings = [
      {
        key = "ctrl+`";
        command = "workbench.action.terminal.toggleTerminal";
      }
      {
        key = "alt+h";
        command = "workbench.action.navigateBack";
        when = "canNavigateBack";
      }
      {
        key = "alt+l";
        command = "workbench.action.navigateForward";
        when = "canNavigateForward";
      }
      {
        key = "ctrl+shift+[";
        command = "workbench.action.toggleSidebarVisibility";
      }
      {
        key = "ctrl+shift+]";
        command = "workbench.action.toggleAuxiliaryBar";
      }
    ];
  };
}
