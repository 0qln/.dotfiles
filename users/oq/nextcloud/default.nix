{ pkgs, ... }:
{
  services.nextcloud-client = {
    enable = true;
  };

  # This is super laggy, so let's just give up on using
  # placeholder files :(
  #
  # VFS support is very poor for nextcloud. so use rclone instead:
  # ref: https://github.com/nextcloud/desktop/issues/3668
  #
  # docs:
  # - rclone options: https://rclone.org/commands/rclone_mount/
  # - rclone config: https://rclone.org/docs/#config-config-file > https://rclone.org/webdav/
  # programs.rclone = {
  #   enable = true;
  #   remotes."nextcloud" = {
  #     config = {
  #       type = "webdav";
  #       url = "https://nextcloud.0qln.duckdns.org/remote.php/dav/files/oq";
  #       vendor = "nextcloud";
  #       user = "oq";
  #       pass = "<invalid>"; # TODO: SOPS
  #       # nextcloud_chunk_size = "1Gi";
  #     };
  #     secrets = {

  #     };
  #     mounts."/" = {
  #       enable = true;
  #       mountPoint = "/home/oq/nextcloud";
  #       options = { };
  #     };
  #   };
  # };

  # davfs2 also doe snot work properly

}
