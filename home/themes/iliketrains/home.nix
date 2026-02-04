{pkgs, ...}: {
  theme.wallpapers = rec {
    arrangements = with images; {
      "|-|" = {
        left = horz1;
        center = horz1;
        right = horz1;
      };
      "-" = {
        center = horz1;
      };
    };
    images = {
      horz1 = pkgs.fetchurl {
        url = "https://w.wallhaven.cc/full/5g/wallhaven-5gx2q5.png";
        hash = "sha256-2gpyEJ9GkTCnVMYbreKXB6QJTVvKc2Up8LHoPCHJ9Os=";
      };
    };
  };
}
