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

      Host kimai.unicorns.software
        HostName kimai.unicorns.software
        IdentityFile ~/.ssh/work/id_ed25519
        User root
        ForwardAgent yes
    '';
  };
}
