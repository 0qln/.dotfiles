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
    rycee.firefox-addons.faststream
    rycee.firefox-addons.dont-track-me-google1
  ]
  ++ [
    (import ./vimium-ff.nix args)
  ])
