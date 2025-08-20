{ config, lib, ... }:
let
  linkPair =
    name: method:
    let
      home = config.home.homeDirectory;
      inherit (config.sops) secrets;
    in
    [
      "L ${home}/.ssh/${name}/${method} - - - - ${secrets."sshKeys/${name}".path}"
      "L ${home}/.ssh/${name}/${method}.pub - - - - ${secrets."sshKeys/${name}.pub".path}"
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

    "sshKeys/work.devops" = {
      format = "binary";
      sopsFile = ./work.devops/id_rsa;
    };
    "sshKeys/work.devops.pub" = {
      format = "binary";
      sopsFile = ./work.devops/id_rsa.pub;
    };
  };

  systemd.user.tmpfiles.rules = lib.lists.flatten [
    (linkPair "server" "id_ed25519")
    (linkPair "work" "id_ed25519")
    (linkPair "work.devops" "rsa")
  ];

  programs.bash.initExtra = ''
    alias ssh-work='ssh -i ~/.ssh/work/id_ed25519'
    alias ssh-devops='ssh -i ~/.ssh/work.devops/id_rsa'
  '';
}
