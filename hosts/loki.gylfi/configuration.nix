{...}: {
  imports = [
    ../../modules/networking
  ];

  home-manager = {
    users.oq = _: {
      settings = {
        enable = true;
        enableWorkSimple = true;
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
