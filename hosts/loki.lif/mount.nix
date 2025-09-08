{...}: {
  # docs: https://nixos.wiki/wiki/Filesystems

  fileSystems."/mnt/lif-data" = {
    device = "/dev/disk/by-uuid/ebd3a8d7-8662-4fe0-bd01-116c00ef3eb3";
    fsType = "ext4";
    options = [
      "nofail"
      "users"
    ];
  };
}
