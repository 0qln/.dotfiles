{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vim
    bc
    wget
    curl
    dig
    age
    jq
  ];
}
