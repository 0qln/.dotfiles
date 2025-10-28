{...}: {
  imports = [
    ../../modules/networking
  ];

  modules.networking = {
    enable = true;
    doh.enable = true;
    localDNS.enable = true;
    localDNS.redirects = [
      "/0qln.duckdns.org/192.168.178.50"
      "/fritz.box/192.168.178.1"
    ];
  };
}
