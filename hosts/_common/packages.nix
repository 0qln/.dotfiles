{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    dig
    age
    jq
  ];
}
