{pkgs-citrix, ...}: {
  imports = [
    ./patches.nix
  ];

  home.packages = with pkgs-citrix; [
    citrix_workspace_24_08_0
  ];
}
