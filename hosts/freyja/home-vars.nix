{lib, ...}: {
  vars = {
    monitors = rec {
      devices = {
        center = {
          name = "eDP-1";
          dim = {
            s = 1.0;
            h = 1200;
            w = 1920;
          };
          workspaces = [1 2 3 4 5 6 7 8 9];
        };
      };

      arrangement = {
        byPictogram = "-";
      };
    };
  };
}
