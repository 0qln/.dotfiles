rec {
  home = home: rec {
    cloud = {
      dir = "${home}/nextcloud";
    };
    pictures = {
      dir = "${cloud.dir}/pictures";
    };
    screenshots = {
      dir = "${pictures.dir}/screenshots";
    };
  };
}
