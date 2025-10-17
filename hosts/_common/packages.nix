{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vim
    bc
    sops
    wget
    curl
    dig
    age
    jq
  ];
}
