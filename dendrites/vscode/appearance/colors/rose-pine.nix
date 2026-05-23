{pkgs, ...}: {
  programs.vscode.profiles.default = {
    extensions = with pkgs.vscode-extensions-patched; [
      mvllow.rose-pine
    ];

    userSettings = {
      "workbench.colorTheme" = "Rosé Pine";
    };
  };
}
