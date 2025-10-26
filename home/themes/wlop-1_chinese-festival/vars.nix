# preferred variables for this theme.
{lib, ...}:
with lib; {
  config.vars = {
    editor = mkDefault "nvim";
    sysfetcher = mkDefault "fastfetch";
    terminal = mkDefault "kitty";
  };
}
