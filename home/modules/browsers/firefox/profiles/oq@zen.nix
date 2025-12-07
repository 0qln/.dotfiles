args @ {pkgs, ...}: {
  id = 0;
  isDefault = true;
  extensions.packages =
    [
      (import ../extensions/zen-internet.nix args)
      (import ../extensions/todoist.nix args)
    ]
    ++ (import ../extensions/_common.nix args);
  search = {
    engines = import ../search-engines pkgs;
    default = "ddg";
  };
}
