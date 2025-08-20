{ ... }:
{
  # sops.secrets = {
  #   "oq-sshKeys-server" = {
  #     format = "binary";
  #     sopsFile = ./server/id_ed25519;

  #   };
  #   "oq-sshKeys-server-pub" = {
  #     format = "binary";
  #     sopsFile = ./server/id_ed25519.pub;
  #   };
  # };
  # home.activation."ssh-keys" = lib.hm.dag.entryAfter [ "writeBoundry" ] ''

  # '';
}
