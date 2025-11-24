{lib, ...}: {
  vars = {
    monitors = rec {
      devices = {
        center = {
          name = "HDMI-A-1";
          hz = 144;
          dim.s = 1.0;
          workspaces = [1 2 3 4 5];
        };

        left = {
          name = "DP-2";
          workspaces = [6 7];
        };

        right = {
          name = "DP-3";
          workspaces = [8 9];
        };
      };

      arrangement = {
        byPictogram = "|-|";
        byName = {
          ${devices.center.name} = {
            y = 550;
          };
        };
      };
    };
  };
}
