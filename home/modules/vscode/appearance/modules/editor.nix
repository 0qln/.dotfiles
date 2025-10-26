profile: {pkgs, ...}: {
  programs.vscode.profiles.${profile} = {
    userSettings = {
      "diffEditor.codeLens" = true;
      "diffEditor.ignoreTrimWhitespace" = false;
      "editor.minimap.showSlider" = "always";
      "editor.foldingHighlight" = false;
      "editor.inlayHints.enabled" = "off";
      "editor.bracketPairColorization.enabled" = false;
      "editor.minimap.renderCharacters" = false;
      "editor.occurrencesHighlight" = "multiFile";
      "editor.fontSize" = 13;
      "editor.fontFamily" = "CartographCF Nerd Font";
      "editor.fontLigatures" = true;
      # "workbench.colorCustomizations": {
      #     "editorError.background":   "#FF000000",
      #     "editorWarning.background":   "#FF000000",
      # },
    };
  };
}
