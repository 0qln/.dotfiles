profile: {pkgs, ...}: {
  imports = [
    (import ../../modules/background/_apoth-1.nix profile)
  ];

  programs.vscode.profiles.${profile} = {
    userSettings = {
      # "background.backgroundOpacity" = [
      #   0.8
      #   0.9
      #   1
      #   1
      # ];
      # "background.backgroundBlur" = [
      #   "0px"
      #   "10"
      #   "0"
      #   "0"
      # ];
      # "background.backgroundSize" = [
      #   "Cover"
      #   "Cover"
      #   "Cover"
      #   "Cover"
      # ];
      # "background.backgroundSizeValue" = [
      #   "100%"
      #   "100%"
      #   "100%"
      #   "100%"
      # ];
    };
  };
}
