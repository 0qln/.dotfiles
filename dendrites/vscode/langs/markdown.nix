profile: {pkgs, ...}: {
  programs.vscode.profiles.${profile} = {
    extensions = with pkgs.vscode-extensions-patched; [
      davidanson.vscode-markdownlint
    ];
  };
}
