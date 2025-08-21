profile:
{ ... }:
{
  imports = [
    (import ../../colors/everforest.nix profile)
  ];

  programs.vscode.profiles.${profile} = {
    userSettings = {
      "everforest.darkContrast" = "hard";
      "everforest.diagnosticTextBackgroundOpacity" = "50%";
      "workbench.colorCustomizations" = {
        "titleBar.border" = "#342d2d";
      };
    };
  };
}
