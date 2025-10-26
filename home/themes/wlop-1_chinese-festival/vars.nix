{config, ...}: {
  config = {
    vars = {
      editor = "nvim";
      sysfetcher = "fastfetch";
      terminal = "kitty";
      theme.name = import ./name.nix;
    };
  };
}
