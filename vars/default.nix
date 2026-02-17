{
  config,
  pkgs,
  ...
}: {
  config.vars = {
    system.default = "x86_64-linux";

    home.config.backup = {
      extension = "hm-bac";
      command = "${pkgs.lib.getExe pkgs.trashy}";
    };

    domains = {
      "0qln.duckdns.org" = {
        dn = "0qln.duckdns.org";
        registrar = "duckdns";
      };
      "07112025.xyz" = {
        dn = "07112025.xyz";
        registrar = "cloudflare";
      };
      "oq.404.mn" = {
        dn = "oq.404.mn";
        registrar = "afraid";
      };
      "nextcloud.myaddr.dev" = {
        dn = "nextcloud.myaddr.dev";
        registrar = "";
      };
    };

    hosts = {
      lifbrasir = {
        fqdns = {
          all = [
            "0qln.duckdns.org"
            "07112025.xyz"
          ];
          primary = config.vars.domains."07112025.xyz";
        };
      };
    };
  };
}
