# https://mynixos.com/home-manager/option/programs.firefox.profiles.%3Cname%3E.search.engines
pkgs: {
  nix-packages = import ./nix-packages.nix pkgs;
  nix-options = import ./nix-options.nix pkgs;
  hm-options = import ./hm-options.nix {};
  nixos-wiki = import ./nixos-wiki.nix {};
  bing.metaData.hidden = true;
  google.metaData.alias = "@g"; # builtin engines only support specifying one additional alias
}
