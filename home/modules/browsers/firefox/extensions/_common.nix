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
    rycee.firefox-addons.return-youtube-dislikes
  ]
  ++ [
    (import ./vimium-ff.nix args)
  ])
