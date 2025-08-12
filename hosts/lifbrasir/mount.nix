{ ... }:
{

  # docs: https://nixos.wiki/wiki/Filesystems

  fileSystems."/mnt/store-1" = {
    device = "/dev/disk/by-uuid/6e282f1d-f6a0-49cd-a6f7-45c6d18e6dfb";
    fsType = "ext4";
    options = [
      "nofail"
      "users"
    ];
  };

}
