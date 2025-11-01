{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.acme;
in {
  options.modules.acme = {
    enable = mkEnableOption "acme";
    duckdnsTokenFile = mkOption {
      type = types.path;
      description = "see https://www.duckdns.org/spec.jsp";
    };
  };

  # docs around acme:
  # https://nixos.org/manual/nixos/stable/index.html#module-security-acme
  config = mkIf cfg.enable {
    sops.secrets."acme/duckdnsToken" = {
      format = "binary";
      sopsFile = cfg.duckdnsTokenFile;
      group = "acme";
    };

    users.users.nginx.extraGroups = ["acme"];

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "linusnag@gmail.com";
      };
      certs."gitea.0qln.duckdns.org" = {
        # https://go-acme.github.io/lego/dns/duckdns/
        dnsProvider = "duckdns";
        environmentFile = "${pkgs.writeText "duckdns-creds" ''
          DUCKDNS_TOKEN_FILE=${config.sops.secrets."acme/duckdnsToken".path}
        ''}";
      };
    };
  };
}
