profile: {pkgs, ...}: {
  imports = [
  ];

  programs.vscode.profiles.${profile} = {
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
    ];

    userSettings = {
    };
  };
}
