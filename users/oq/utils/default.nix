{
  lib,
  pkgs,
  config,
  sysConfig,
  ...
}:
{
  mkSecretLink =
    {
      secret, # can also contain a path e.g. todoist/todoist-token
      destPath, # Full destination path (e.g., "${config.xdg.configHome}/todoist/config.json")
      deps ? [ "writeBoundary" ],
    }:
    lib.hm.dag.entryAfter deps ''
      #!${pkgs.bash}/bin/bash
      dst="${destPath}"
      src="$XDG_RUNTIME_DIR/secrets/${secret}"
      if [[ ! -e "$dst" ]]; then
        mkdir -p "$(dirname "$dst")"
        ln -s "$src" "$dst"
      fi
    '';

  mkForceSecretLink =
    {
      secret, # can also contain a path e.g. todoist/todoist-token
      destPath, # Full destination path (e.g., "${config.xdg.configHome}/todoist/config.json")
      deps ? [ "writeBoundary" ],
    }:
    lib.hm.dag.entryAfter deps ''
      #!${pkgs.bash}/bin/bash
      dst="${destPath}"
      src="$XDG_RUNTIME_DIR/secrets/${secret}"
      if [[ ! -e "$dst" ]]; then
        rm "$("$dst")"
      fi
      ln -s "$src" "$dst"
    '';

  userRuntimeDir = "/run/user/${toString sysConfig.users.users.${config.home.username}.uid}";
}
