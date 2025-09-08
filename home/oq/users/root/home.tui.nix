{...}: {
  home-manager.users.root = {...}: {
    imports = [
      ./home._common.nix
    ];
  };
}
