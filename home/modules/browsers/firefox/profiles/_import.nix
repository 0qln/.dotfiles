args @ {
  lib,
  pkgs,
  ...
}:
with lib; let
  mkProfile = p: (nameValuePair p (import ./${p}.nix args));
  profiles = map mkProfile args.profiles;
  ids = lists.range 0 (builtins.length profiles);
  result = lists.zipListsWith (profile: id: nameValuePair profile.name (profile.value // {inherit id;})) profiles ids;
in
  builtins.listToAttrs result
