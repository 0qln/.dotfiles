profile: {pkgs, ...}: {
  programs.vscode.profiles.${profile} = {
    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "kanagawa-vscode";
        publisher = "beeverfeever";
        version = "0.0.2";
        sha256 = "sha256-DWR7I4/MaX3NZqb26wlye1UalOUZdAZmpbSGep5i4OU=";
      }
    ];

    userSettings = {
      "workbench.colorTheme" = "Kanagawa Vscode";
    };
  };
}
