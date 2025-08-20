{ config, lib, ... }:
let
  linkPair =
    name:
    let
      home = config.home.homeDirectory;
      inherit (config.sops) secrets;
    in
    [
      "L ${home}/.ssh/${name}/id_ed25519 - - - - ${secrets."sshKeys/${name}".path}"
      "L ${home}/.ssh/${name}/id_ed25519.pub - - - - ${secrets."sshKeys/${name}.pub".path}"
    ];
in
{
  sops.secrets = {
    "sshKeys/server" = {
      format = "binary";
      sopsFile = ./server/id_ed25519;
    };
    "sshKeys/server.pub" = {
      format = "binary";
      sopsFile = ./server/id_ed25519.pub;
    };

    "sshKeys/work" = {
      format = "binary";
      sopsFile = ./work/id_ed25519;
    };
    "sshKeys/work.pub" = {
      format = "binary";
      sopsFile = ./work/id_ed25519.pub;
    };
  };

  systemd.user.tmpfiles.rules = lib.lists.flatten [
    (linkPair "work")
    (linkPair "server")
  ];

  programs.bash.initExtra = ''
    alias ssh-work='ssh -i ~/.ssh/work/id_ed25519'
  '';
}
