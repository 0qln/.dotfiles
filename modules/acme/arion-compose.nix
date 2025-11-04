# https://nginxproxymanager.com/guide/
dataDir: {
  project.name = "nginx-proxy-manager";

  services.app = {
    service = {
      image = "jc21/nginx-proxy-manager:latest";
      restart = "unless-stopped";
      ports = [
        "81:81"
        # conflicting with nginx:
        # "80:80"
        # "443:443"
      ];
      volumes = [
        "${dataDir}/data:/data"
        "${dataDir}/letsencrypt:/etc/letsencrypt"
      ];
    };
  };
}
