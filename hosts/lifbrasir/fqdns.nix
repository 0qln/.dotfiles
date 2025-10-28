rec {
  primary = "0qln.duckdns.org";
  secondary = [
    # "oq.404.mn"
    # "nextcloud.myaddr.dev" TODO
  ];
  all = [primary] ++ secondary;
}
