{...}: {
  programs.nixvim = {
    plugins = {
      #TODO: intgrate with ueberzugpp (already installed bc of ../../modules/lf)
      image.enable = true;
    };
  };
}
