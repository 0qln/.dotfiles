{flake, ...}: {
  imports = [
    flake.nixosModules.odoo
  ];

  modules = {
    odoo.enable = true;
  };

  home-manager = {
    users.oq = _: {
      imports = [
        flake.homeModules.odoo
      ];

      settings = {
        enable = true;
        enableWorkSimple = true;
      };

      modules = {
        odoo.enable = true;
      };

      private = {
        secrets.ssh = {
          server = true;
          work = true;
          work-devops = true;
        };
      };
    };
  };
}
