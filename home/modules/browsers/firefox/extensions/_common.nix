args @ {
  lib,
  config,
  pkgs,
  ...
}:
# https://nur.nix-community.org/
(with pkgs.nur.repos;
  [
    rycee.firefox-addons.privacy-badger
    rycee.firefox-addons.ublock-origin
    rycee.firefox-addons.bitwarden
    rycee.firefox-addons.darkreader
  ]
  ++ [
    (import ./vimium-ff.nix args)
  ])
