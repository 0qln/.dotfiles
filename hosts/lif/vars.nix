{lib, ...}: {
  vars = {
    monitors = rec {
      devices = {
        center = {
          name = "HDMI-A-1";
          hz = 144;
          dim.s = 1.0;
        };

        left = {
          name = "DP-3";
        };

        right = {
          name = "DP-2";
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
