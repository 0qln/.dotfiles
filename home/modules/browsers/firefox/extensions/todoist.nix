{
  lib,
  config,
  ...
}:
config.utils.buildFirefoxXpiAddon {
  pname = "todoist";
  version = "12.13";
  addonId = "{52c6ed08-f58d-4c29-a949-cad38a73597a}";
  url = "https://addons.mozilla.org/firefox/downloads/file/4551580/todoist-12.13.xpi";
  sha256 = "sha256-LQl8QeM53wS1PDLuA0xaqV+ndwilhTtqRaquiTEXyn0=";
  meta = with lib; {
    mozPermissions = [
      "activeTab"
      "tabs"
    ];
    platforms = platforms.all;
  };
}
