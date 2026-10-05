profile: {pkgs, ...}: {
  programs.vscode.profiles.${profile} = {
    extensions = with pkgs.vscode-extensions-patched; [
      # the debug adapter that the generated launch.json in the plugin
      # workspace ("kimai: listen for xdebug") drives
      xdebug.php-debug
    ];
  };
}
