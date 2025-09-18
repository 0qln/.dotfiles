{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    age
    jq
  ];
}
