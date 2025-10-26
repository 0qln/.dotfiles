{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    golangci-lint
  ];

  programs.nixvim = {
    plugins = {
      neotest = {
        adapters.go.enable = config.programs.nixvim.plugins.neotest.enable && true;
      };
    };
  };
}
