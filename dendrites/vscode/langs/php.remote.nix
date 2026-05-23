profile: {...}: {
  programs.vscode.profiles.${profile} = {
    userSettings = {
      "intelephense.telemetry.enabled" = false;
    };
  };
}
