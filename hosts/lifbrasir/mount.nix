{ ... }: {

  # docs: https://nixos.wiki/wiki/Filesystems

  fileSystems."/mnt/store-1" = {
    device = "/dev/disk/by-uuid/3284-E8C7";
    fsType = "vfat";
    options = [
      "nofail"
      "users"
    ];
  };

}
