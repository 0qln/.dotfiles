_: {
  imports = let
    paths = builtins.readDir ./.;
    langs = builtins.filter (isLng && isMod) (builtins.attrNames paths);
    store = map (l: ./${l}) langs;
    isMod = name: builtins.match ".*\\.nix$" name != null;
    isLng = name: name != "_all.nix";
  in
    store;
}
