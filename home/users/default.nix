# This imports all the modules
{lib, ...}: {
  imports = with builtins; let
    isDir = type: type == "directory";
    isMod = _f: t: (isDir t);
    modul = lib.attrsets.filterAttrs isMod (readDir ./.);
    names = attrNames modul;
    paths = map (n: ./${n}) names;
  in
    paths;
}
