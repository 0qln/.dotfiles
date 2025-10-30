{inputs, ...}: {
  imports = [
    inputs.private.nixosModules."lif"
  ];

  home-manager = {
    users.oq = _: {
      imports = [./vars.nix];
      settings = {
        enable = true;
        uiEnv = "tui";
      };
      private = {
        secrets.ssh = {
          server = true;
        };
      };
    };
  };
}
