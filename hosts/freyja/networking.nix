{config, ...}: {
  imports = [
    ../../modules/networking
  ];

  modules.networking = {
    enable = true;
    doh.enable = true;
  };
}
