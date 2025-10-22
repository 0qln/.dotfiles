{...}: {
  imports = [
    ./user.nix
  ];

  home-manager.users.root = import ./home.nix;
}
