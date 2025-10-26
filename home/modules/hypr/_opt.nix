{lib, ...}:
with lib; {
  options.modules.hypr = {
    enable = mkEnableOption "hypr";
  };
}
