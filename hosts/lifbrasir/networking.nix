{config, ...}: {
  modules.networking = {
    enable = true;
    localDNS.enable = true;
    localDNS.redirects =
      ["/fritz.box/192.168.178.1"]
      ++ (map (x: "/${x}/127.0.0.1") config.vars.hosts.lifbrasir.fqdns.all);
  };
}
