# we can even extend imperatively created profiles :D
{pkgs, ...}: {
  id = 2;
  isDefault = false;
  path = "89h16xs5.Default (alpha)";
  search = {
    engines = import ../search-engines pkgs;
    default = "ddg";
  };
}
