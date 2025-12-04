{
  lib,
  config,
  ...
}:
# see:
#
# generate bulk:
# - nur package: https://github.com/nix-community/nur-combined/blob/main/repos/rycee/pkgs/mozilla-addons-to-nix/default.nix
# - nur source: https://git.sr.ht/~rycee/mozilla-addons-to-nix/
# e.g.:
# - input json: https://github.com/nix-community/nur-combined/blob/main/repos/rycee/pkgs/firefox-addons/addons.json
# - output nix: https://github.com/nix-community/nur-combined/blob/main/repos/rycee/pkgs/firefox-addons/generated-firefox-addons.nix
#
# or manual: e.g.:
# - https://github.com/nix-community/nur-combined/blob/e60d2cac468d38a97874108c1601de2ce0ca23b8/repos/rycee/pkgs/firefox-addons/zotero.nix
#
# some of the info can be found in the manifest file:
# https://github.com/sameerasw/zeninternet/blob/master/manifest.json
config.utils.buildFirefoxXpiAddon {
  pname = "transparent-zen";
  version = "2.7.0";
  addonId = "{91aa3897-2634-4a8a-9092-279db23a7689}";
  url = "https://addons.mozilla.org/firefox/downloads/file/4537733/zen_internet-2.7.0.xpi";
  sha256 = "sha256-PEPoQRNjiO6lSjv5yZNIK16qYgJaeJWoUquqbEZR01o=";
  meta = with lib; {
    description = "Make the internet feel native and elegant. Zen Internet is a browser extension that enhances your browsing experience by providing a clean and minimalistic interface with transparency and a focus on content. Customize the features in the addon popup.";
    license = licenses.mit;
    mozPermissions = [
      "activeTab"
      "storage"
      "tabs"
      "<all_urls>"
      "webNavigation"
      "webRequest"
      "webRequestBlocking"
    ];
    platforms = platforms.all;
  };
}
