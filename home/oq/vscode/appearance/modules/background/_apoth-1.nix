profile:
{ pkgs, ... }:
{
  imports = [
    (import ./default.nix profile)
  ];

  programs.vscode.profiles.${profile} = {

    userSettings = {
      # "backgroundCover.imagePath" = "${pkgs.fetchurl {
      #   url = "https =//w.wallhaven.cc/full/qz/wallhaven-qzv6rd.jpg";
      #   hash = "sha256-2agGcbQS3oUcdvnQM0VP1YBQwG0RFBYr4A63KLTmMIU=";
      # }}";
      # "background.filepath" = "${pkgs.fetchurl {
      #   url = "https =//w.wallhaven.cc/full/qz/wallhaven-qzv6rd.jpg";
      #   hash = "sha256-2agGcbQS3oUcdvnQM0VP1YBQwG0RFBYr4A63KLTmMIU=";
      # }}";
      # "background.fullscreen" = {
      #   "images" = [
      #     "file://${
      #       pkgs.fetchurl {
      #         url = "https =//w.wallhaven.cc/full/qz/wallhaven-qzv6rd.jpg";
      #         hash = "sha256-2agGcbQS3oUcdvnQM0VP1YBQwG0RFBYr4A63KLTmMIU=";
      #       }
      #     }"
      #   ];
      #   "opacity" = 0.2;
      #   "size" = "cover";
      #   "position" = "center";
      #   "interval" = 0;
      #   "random" = false;
      # };
      # "background.windowBackgrounds" = [
      #
      # ];
      # "background.backgroundAlignment" = [
      #   "Top Center"
      #   "Center Center"
      #   "Center Center"
      #   "Center Center"
      # ];
      # "workbench.localHistory.enabled" = true;
      # "settingsSync.ignoredExtensions" = [
      #   "katsute.code-background"
      # ];
    };

  };
}
