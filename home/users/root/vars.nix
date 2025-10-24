{
  config,
  lib,
  ...
}:
with lib; {
  config.vars = let
    root =
      if builtins.hasAttr "home" config
      then config.home.homeDirectory
      else "/root/";
  in {
    user.uid = mkForce (import ./uuid.nix);
    root = mkDefault root;
  };
}
