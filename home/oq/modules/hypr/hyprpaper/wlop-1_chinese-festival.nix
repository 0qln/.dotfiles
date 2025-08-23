{
  pkgs,
  monitors,
  lib,
  ...
}:
let
  wals = {
    vert1 = "${pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/ex/wallhaven-exj8jl.jpg";
      hash = "sha256-sC6gYIAgTlFNFdn9dbvPj3ZQ6u6KGX5ImyHRU/BZ2bw=";
    }}";
    vert2 = "${pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/o3/wallhaven-o3k6ol.jpg";
      hash = "sha256-g5XH8n+rZnr1fw2YifqzxWJto8UeBo3VBOPYyrGxgtg=";
    }}";
    horz1 = "${pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/p9/wallhaven-p9vyz3.jpg";
      hash = "sha256-bo2omvgTQ8oOoAbuxXTiRLSVAevUA4Tu60IUHCM99bA=";
    }}";
  };
in
{
  services.hyprpaper = {
    settings = {
      preload = lib.attrsets.attrValues wals;
      wallpaper = with wals; [
        "${monitors.left}, ${vert1}"
        "${monitors.center}, ${horz1}"
        "${monitors.right}, ${vert2}"
      ];
    };
  };
}
