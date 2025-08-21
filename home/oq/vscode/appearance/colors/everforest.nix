profile:
{ pkgs, ... }:
{
  programs.vscode.profiles.${profile} = {

    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "everforest";
        publisher = "sainnhe";
        version = "0.3.0";
        sha256 = "sha256-nZirzVvM160ZTpBLTimL2X35sIGy5j2LQOok7a2Yc7U=";
      }
    ];

    userSettings = {
      "workbench.colorTheme" = "Everforest Dark";
      "everforest.darkContrast" = "hard";
      "everforest.diagnosticTextBackgroundOpacity" = "50%";
    };

  };
}
