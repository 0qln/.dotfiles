{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    rofi
  ];

  home.file.".config/rofi" = {
    source = config.lib.file.mkOutOfStoreSymlink ./rasi;
    recursive = true;
  };
}
