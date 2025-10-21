{pkgs, ...}: {
  home.packages = with pkgs; [
    # files
    fzf
    fd
    tree
    unzip
    ripgrep
    srm

    # images/videos
    ffmpeg
    mpv
    imagemagick
    qimgv
    vlc

    # networking
    iperf3

    # super important
    fastfetch
  ];
}
