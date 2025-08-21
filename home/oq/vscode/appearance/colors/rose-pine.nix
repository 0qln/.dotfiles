{ pkgs, ... }:
{
  programs.vscode.profiles.default = {

    extensions = with pkgs.vscode-extensions; [
      mvllow.rose-pine
    ];

    userSettings = {
      "workbench.colorTheme" = "Rosé Pine";
    };

  };
}
