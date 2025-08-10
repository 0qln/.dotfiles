{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # files
    fzf
    fd
    tree
    unzip
    ripgrep

    # images/videos
    ffmpeg
    mpv
    imagemagick
    qimgv
  ];
}
