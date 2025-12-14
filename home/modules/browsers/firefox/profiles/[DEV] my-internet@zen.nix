args @ {...}:
# https://mynixos.com/home-manager/option/programs.firefox.profiles.%3Cname%3E.extensions.packages
{
  isDefault = false;
  extensions.packages = [
    (import ../extensions/zen-internet.nix args)
  ];
  settings = {
    # automatically enable extensions
    "extensions.autoDisableScopes" = 0;
  };
}
