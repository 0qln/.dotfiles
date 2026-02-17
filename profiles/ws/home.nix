{...}: {
  settings = {
    enableWorkSimple = true;
  };

  private = {
    secrets.ssh = {
      work = true;
      work-devops = true;
    };
  };
}
