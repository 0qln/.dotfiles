{...}: let
  # https://www.freedesktop.org/software/systemd/man/latest/systemd.mount.html
  lazyMount = [
    "noauto"
    "x-systemd.automount"
  ];
in {
  # docs: https://nixos.wiki/wiki/Filesystems

  fileSystems."/mnt/store-1" = {
    device = "/dev/disk/by-uuid/6e282f1d-f6a0-49cd-a6f7-45c6d18e6dfb";
    fsType = "ext4";
    options = ["nofail"] ++ lazyMount;
  };

  fileSystems."/mnt/store-2" = {
    device = "/dev/disk/by-uuid/edac87da-fcbb-42a6-924e-ecfed9a6324a";
    fsType = "ext4";
    options = ["nofail" "users"] ++ lazyMount;
  };
}
