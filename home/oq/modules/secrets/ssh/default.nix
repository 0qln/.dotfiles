#>
#> Note:
#> This breaks for the root user.
#> I don't know why but it just does and then systemd fails
#> to find the sops-nix.service because idkklklj;lkjasd;lfkjalkfj
#>
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
      mode = "0600";
    };
    "sshKeys/server.pub" = {
      format = "binary";
      sopsFile = ./server/id_ed25519.pub;
      mode = "0644";
    };

    "sshKeys/work" = {
      format = "binary";
      sopsFile = ./work/id_ed25519;
      mode = "0600";
    };
    "sshKeys/work.pub" = {
      format = "binary";
      sopsFile = ./work/id_ed25519.pub;
      mode = "0644";
    };

    "sshKeys/work.devops" = {
      format = "binary";
      sopsFile = ./work.devops/id_rsa;
      mode = "0600";
    };
    "sshKeys/work.devops.pub" = {
      format = "binary";
      sopsFile = ./work.devops/id_rsa.pub;
      mode = "0644";
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
