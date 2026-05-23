profile: {pkgs, ...}: {
  programs.vscode.profiles.${profile} = {
    extensions = with pkgs.vscode-extensions-patched; [
      asvetliakov.vscode-neovim
    ];

    userSettings = {
      "extensions.experimental.affinity" = {
        "asvetliakov.vscode-neovim" = 1;
      };
      "editor.lineNumbers" = "relative";
    };
  };
}
