{config, ...}: {
  imports = [
    # Import default values.
    ./defaultConfig.nix
  ];

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host lifbrasir
        IdentityFile ${config.home.homeDirectory}/.ssh/server/id_ed25519
        User root
        IdentitiesOnly yes
        AddKeysToAgent yes

      Host kimai.unicorns.software
        HostName kimai.unicorns.software
        IdentityFile ${config.home.homeDirectory}/.ssh/work/id_ed25519
        User root
        ForwardAgent yes

      Host odoo-dev.worksimple.de
        HostName odoo-dev.worksimple.de
        IdentityFile ${config.home.homeDirectory}/.ssh/work/id_ed25519
        User root
        ForwardAgent yes
    '';
  };
}
