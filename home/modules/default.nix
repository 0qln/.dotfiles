# This imports all the modules
_: {
  imports = with builtins; let
    isDir = type: type == "directory";
    isMod = _f: t: (isDir t);
    modules = filter isMod (readDir ./.);
  in
    modules;
}
