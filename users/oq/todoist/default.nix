{
  pkgs,
  lib,
  sops-nix,
  config,
  ...
}:
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

  home.activation.todoist-token = lib.hm.dag.entryAfter [ "writeBoundry" ] ''
    #!${pkgs.bash}/bin/bash
    dst=${config.xdg.configHome}/todoist/config.json
    src=/run/user/1000/secrets/todoist-token
    [[ -e "$dst" ]] || {
      ln -s "$src" "$dst"
    }
  '';
}
