profile: {pkgs, ...}: {
  programs.vscode.profiles.${profile} = {
    extensions = with pkgs.vscode-extensions-patched; [
      tal7aouy.icons
    ];

    userSettings = {
      "vsicons.dontShowNewVersionMessage" = true;
    };
  };
}
