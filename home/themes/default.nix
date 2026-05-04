# This imports all the modules
{utilz, ...}: {
  imports = let
    themes = utilz.mods.collectMods ./.;
    paths = []; # map (n: ./${n}) themes;
  in
    paths ++ [./opts.nix];
}
