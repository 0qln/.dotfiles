{ ... }:
{

  # docs: https://nixos.wiki/wiki/Filesystems

  fileSystems."/mnt/volume-d" = {
    device = "/dev/disk/by-uuid/DEE03199E03178BB";
    fsType = "ntfs";
    options = [
      "nofail"
      "users"
    ];
  };

  fileSystems."/mnt/volume-c" = {
    device = "/dev/disk/by-uuid/48CAF2AACAF29402";
    fsType = "ntfs";
    options = [
      "nofail"
      "users"
    ];
  };

  # fileSystems."/boot/windows-efi" = {
  #   device = "/dev/disk/by-uuid/3CEB-ADB5";
  #   fsType = "vfat";
  #   options = [
  #     "nofail"
  #     "users"
  #   ];
  # };

  # fileSystems."/boot/EFI/Microsoft" = {
  #   depends = [
  #     "/boot/windows-efi"
  #   ];
  #   device = "/boot/windows-efi/EFI/Microsoft";
  #   fsType = "none";
  #   options = [
  #     "bind"
  #     "ro"
  #   ];
  # };
}
