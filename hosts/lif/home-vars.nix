{lib, ...}: {
  # todo: the worksimple is globally enable for this host such that the setting is enabled
  # for the odoo dev profile... create a hardcoded profile for home-manager or something
  # such that this is not forced for all build on this host.
  settings = {
    enableWorkSimple = true;
  };

  private = {
    secrets.ssh = {
      work = true;
      work-devops = true;
    };
  };

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
          name = "DP-3";
          workspaces = [6 7];
        };

        right = {
          name = "DP-2";
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
