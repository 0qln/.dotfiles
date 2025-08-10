{ ... }:
{
  config = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    users.extraUsers.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHGSLpGhb4X7V6eDVqXq9uzUth9xfHJsSugmOZzS+qt1 user@Linus-PC"
    ];

    networking.firewall.allowedTCPPorts = [ 22 ];
  };
}
