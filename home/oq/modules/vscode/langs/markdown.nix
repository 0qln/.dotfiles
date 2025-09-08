profile: {pkgs, ...}: {
  programs.vscode.profiles.${profile} = {
    extensions = with pkgs.vscode-extensions; [
      davidanson.vscode-markdownlint
    ];
  };
}
