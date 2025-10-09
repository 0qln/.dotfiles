_: {
  imports = let
    paths = builtins.readDir ./.;
    langs = builtins.filter (n: isLng n && isMod n) (builtins.attrNames paths);
    store = map (l: ./${l}) langs;
    isMod = name: builtins.match ".*\\.nix$" name != null;
    isLng = name: name != "_all.nix";
  in
    store;
}
