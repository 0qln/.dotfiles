profile: {pkgs, ...}: {
  programs.vscode.profiles = {
    ${profile} = {
      extensions = with pkgs.vscode-extensions; [
        (eamodio.gitlens.overrideAttrs (_old: {
          vscodeExtUniqueId = "eamodio.gitlens";
        }))
      ];
      userSettings = {
        "git.openRepositoryInParentFolders" = "always";
        "git.autofetch" = true;
      };
    };
  };
}
