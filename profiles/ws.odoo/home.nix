{...}: {
  imports = [
    ../ws/home.nix
    ../python/home.nix
  ];

  home.file."odoo-wrap".source = ./bin/odoo-wrap;
}
