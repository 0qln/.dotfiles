profile: {pkgs, ...}: {
  imports = [
    (import ./php.remote.nix profile)
  ];

  programs.vscode.profiles.${profile} = {
    extensions = with pkgs.vscode-extensions-patched; [
      bmewburn.vscode-intelephense-client
    ];

    userSettings = {
      "[php]" = {
        "editor.defaultFormatter" = "bmewburn.vscode-intelephense-client";
      };
    };
  };
}
