{...}: rec {
  config = {
    vars = {
      editor = "nvim";
      sysfetcher = "fastfetch";
      terminal = "kitty";
      theme.name = builtins.dirOf __curPos.file;
    };
  };
}
