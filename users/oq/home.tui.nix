{ ... }:
{
  home-manager.users.oq =
    { ... }:
    {
      imports = [
        ./home._common.nix
        ./tmux
      ];
    };
}
