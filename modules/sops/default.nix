{ config, sops-nix, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    sops
  ];

  sops = {
    defaultSopsFormat = "yaml";
    age.keyFile = "/root/.config/sops/age/keys.txt";
  };
}
