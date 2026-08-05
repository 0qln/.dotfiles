_: {
  imports = with builtins; let
    ident = baseNameOf __curPos.file;
    names = attrNames paths;
    paths = readDir ./.;
    langs = filter (n: n != ident && isMod n != null) names;
    isMod = match ".*\\.nix$";
    store = map (l: ./${l}) langs;
  in
    store;
}
