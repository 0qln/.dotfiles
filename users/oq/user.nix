{ ... }:
{
  users.users.oq = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
