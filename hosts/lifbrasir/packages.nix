{ pkgs, ... }:
{

  # List packages installed in system profile. To search, run:
  #TODO: clean this
  environment.systemPackages = with pkgs; [
    vim
    wget
    gh
    sops
  ];

}
