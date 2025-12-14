# we can even extend imperatively created profiles :D
{pkgs, ...}: {
  isDefault = true;
  path = "89h16xs5.Default (alpha)";
  search = {
    engines = import ../search-engines pkgs;
    default = "ddg";
  };
}
