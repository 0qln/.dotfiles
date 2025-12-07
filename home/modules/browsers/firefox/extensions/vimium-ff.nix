{
  lib,
  config,
  ...
}:
config.utils.buildFirefoxXpiAddon {
  pname = "vimium-ff";
  version = "2.3.1";
  addonId = "{d7742d87-e61d-4b78-b8a1-b469842139fa}";
  url = "https://addons.mozilla.org/firefox/downloads/file/4618554/vimium_ff-2.3.1.xpi";
  sha256 = "sha256-LBuGHLQZOcKibk5guV0edORl6AfCxUmjDJCcGSNZFHM=";
  meta = with lib; {
    mozPermissions = [
      "<all_urls>"
      "tabs"
      "bookmarks"
      "history"
      "storage"
      "sessions"
      "notifications"
      "scripting"
      "favicon"
      "webNavigation"
      "search"
    ];
    platforms = platforms.all;
  };
}
