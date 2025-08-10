{ ... }:
{
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host lifbrasir
        IdentityFile /home/oq/.ssh/server/id_ed25519
        User root
        IdentitiesOnly yes
        AddKeysToAgent yes
    '';
  };
}
