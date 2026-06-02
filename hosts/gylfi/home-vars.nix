{lib, ...}: {
  vars = {
    monitors = rec {
      devices = {
        center = {
          name = "<invalid>";
          dim = {
            s = 1.0;
            h = 1080;
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
