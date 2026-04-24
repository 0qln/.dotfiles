{config, ...}: {
  modules.networking = {
    enable = true;
    doh.enable = true;
    localDNS.enable = true;
    localDNS.redirects =
      ["/fritz.box/192.168.178.1"]
      ++ (map (x: "/${x}/192.168.178.50") config.vars.hosts.lifbrasir.fqdns.all);
  };
}
