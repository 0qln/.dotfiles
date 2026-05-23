profile: {pkgs, ...}: {
  imports = [
  ];

  programs.vscode.profiles.${profile} = {
    extensions = with pkgs.vscode-extensions; [
      # todo: fuckass dependency error: jedi<0.20,>=0.19.2 not satisfied by version 0.20.0
      # ms-python.python
    ];

    userSettings = {
    };
  };
}
