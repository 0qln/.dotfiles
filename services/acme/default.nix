{ ... }:
{
  # docs around acme:
  # - https://nixos.org/manual/nixos/stable/index.html#module-security-acme
  # -
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "linusnag@gmail.com";
    };
  };
}
