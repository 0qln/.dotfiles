{lib, ...}: {
  vars = {
    monitors = rec {
      devices = {
        center = {
          name = "tmp";
	  dim.s = 1.0;
          workspaces = [1 2 3 4 5 6 7 8 9];
        };
      };

      arrangement = {
        byPictogram = "-";
      };
    };
  };
}
