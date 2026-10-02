{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.harmonia = {config, ...}: let
    cfg = config.modules.harmonia;
    port = 5000;
  in {
    options.modules.harmonia = {
      enable = mkEnableOption "harmonia binary cache";

      signKeyFile = mkOption {
        type = types.path;
        description = ''
          The sops encrypted nix signing key. Harmonia generates and signs the
          narinfo itself, so paths pushed here by other machines come out signed
          with this key no matter who built them.
          Generate with `nix key generate-secret --key-name <fqdn>-1`; the
          matching public key belongs in `modules.nix.caches` on the clients.
        '';
      };

      basicAuthFile = mkOption {
        type = types.path;
        description = ''
          The sops encrypted htpasswd file guarding the cache. Harmonia serves
          the whole store, so without this anyone who learns a store path can
          fetch it.
        '';
      };

      fqdn = {
        dn = mkOption {
          type = types.str;
          description = "The primary fqdn.";
        };
        acmeHost = mkOption {
          type = types.str;
          description = "The host domain that has an ssl certificate.";
        };
      };
    };

    config = mkIf cfg.enable {
      # harmonia runs under DynamicUser and reads the key through systemd's
      # LoadCredential, so this one stays root owned.
      sops.secrets."harmonia/signKey" = {
        sopsFile = cfg.signKeyFile;
        mode = "0400";
        format = "binary";
      };

      sops.secrets."harmonia/basicAuth" = {
        sopsFile = cfg.basicAuthFile;
        owner = config.services.nginx.user;
        mode = "0400";
        format = "binary";
      };

      services.harmonia.cache = {
        enable = true;
        signKeyPaths = [config.sops.secrets."harmonia/signKey".path];
        # the nixos module defaults the advertised priority to 50, which keeps
        # cache.nixos.org (40) ahead of this one for paths both of them have.
        settings.bind = "127.0.0.1:${toString port}";
      };

      # Paths pushed here are referenced by nothing on this host, so a garbage
      # collection would drop the whole cache. Pushers root their closures in
      # here instead.
      systemd.tmpfiles.rules = [
        "d /nix/var/nix/gcroots/dots-cache 0755 root root - -"
      ];

      modules.acme.certs.${cfg.fqdn.acmeHost}.aliases = [cfg.fqdn.dn];

      services.nginx.virtualHosts.${cfg.fqdn.dn} = {
        forceSSL = true;
        useACMEHost = cfg.fqdn.acmeHost;
        basicAuthFile = config.sops.secrets."harmonia/basicAuth".path;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          extraConfig = ''
            # nars are large and harmonia already compresses them; buffering
            # them to disk and recompressing only adds latency.
            proxy_buffering off;
            proxy_read_timeout 300s;
            gzip off;
          '';
        };
      };
    };
  };
}
