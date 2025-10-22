{...}: {
  imports = [./user.nix];
  home-manager.users.oq = import ./home.nix;
}
