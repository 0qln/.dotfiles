{
  import-module = path: args: let
    config = import path ({inherit (config) config;} // args);
  in
    config.config;
}
