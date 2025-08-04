{
  pkgs,
  lib,
  sops-nix,
  config,
  sysConfig,
  ...
}:
let
  # utils = pkgs.callPackage ../utils { inherit lib sysConfig config; };

  #TODO: figure out how to pass the args to utils and then use the utils...
  mkForceCopySecret =
    {
      secret, # can also contain a path e.g. todoist/todoist-token
      destPath, # Full destination path (e.g., "${config.xdg.configHome}/todoist/config.json")
      deps ? [ "writeBoundary" ],
    }:
    lib.hm.dag.entryAfter deps ''
      #!${pkgs.bash}/bin/bash
      dst="${destPath}"
      src="$XDG_RUNTIME_DIR/secrets/${secret}"
      if [[ -e "$dst" ]]; then
        run rm -r "$dst"
      fi
      # the todoist-cli cannot handle soft symlinks. hardlinks break
      # break because XDG_RUNTIME_DIR is usually /run/user/..., which is
      # an in-memory filesystem.
      # so we have no other option but to copy :(
      # (we could bind the file systems, but that's just overkill)
      run cp -Lrp "$src" "$dst"
    '';
in
{
  home.packages = with pkgs; [
    todoist-electron
    todoist
  ];

  sops.secrets."todoist-token" = {
    format = "json";
    sopsFile = ./secrets.json;
    key = "";
    mode = "0600";
  };

  home.activation.todoist-token = mkForceCopySecret {
    secret = "todoist-token";
    destPath = "${config.xdg.configHome}/todoist/config.json";
  };
}
