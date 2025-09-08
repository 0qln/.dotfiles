{pkgs, ...}: {
  home.file.".config/vesktop/themes/dark-matter.theme.css" = {
    source = "${pkgs.fetchurl {
      url = "https://betterdiscord.app/Download?id=174";
      hash = "sha256-BkWCSLP34edKgAbTbBrcy83yS28+rkRXnQu1YQciz74=";
    }}";
  };
}
