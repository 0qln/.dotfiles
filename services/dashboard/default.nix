{ config, lib, pkgs, ... }:
let
  serviceName = "dashboard";
  serviceUser = "dashboard";
  serviceGroup = "dashboard";
  servicePkgs = import ./packages.nix { inherit pkgs; };
  service = pkgs.callPackage ./derivation.nix { name = serviceName; inherit servicePkgs; };
in {
  options.services.${serviceName} = {
    enable = lib.mkEnableOption "Dashboard";
  };

  config = lib.mkIf config.services.${serviceName}.enable {
    # Dedicated user
    users.groups.${serviceGroup} = {};
    users.users.${serviceUser} = {
      group = serviceGroup;
      isNormalUser = true;
      packages = servicePkgs;
      hashedPassword = "!"; # Lock Password
      extraGroups = [ "tty" ];
    };

    # Set session as startup
    systemd.services."getty@tty1" = {
      enable = true;
      overrideStrategy = "asDropin";
      serviceConfig = {
        # Documentation
        # https://www.freedesktop.org/software/systemd/man/latest/systemd.directives.html
        # https://raymii.org/s/tutorials/Run_software_on_tty1_console_instead_of_login_getty.html
        # https://wiki.archlinux.org/title/Getty
        # https://man.sr.ht/%7Ekennylevinsen/greetd/#setting-up-auto-login
        # https://unix.stackexchange.com/questions/253928/how-to-configure-agetty-to-autologon-on-only-one-terminal
        # https://gist.github.com/caadar/7884b1bf16cb1fc2c7cde33d329ae37f
        # https://man7.org/linux/man-pages/man8/agetty.8.htmlhttps://man7.org/linux/man-pages/man8/agetty.8.html
        Type = "simple";
        ExecStart = lib.mkForce [ "" "${service}/bin/${serviceName}" ];
        StandardOutput = "tty";
        StandardInput = "tty";
        User = serviceUser;
        Group = serviceGroup;
        # Grant required capabilities directly
        AmbientCapabilities = [
          "CAP_NET_ADMIN"
          "CAP_NET_RAW"
          "CAP_DAC_READ_SEARCH"
          "CAP_SYS_PTRACE"
        ];
        CapabilityBoundingSet = [
          "CAP_NET_ADMIN"
          "CAP_NET_RAW"
          "CAP_DAC_READ_SEARCH"
          "CAP_SYS_PTRACE"
        ];
      };
    };
  };
}
