profile: {...}: {
  imports = [
    (import ./php.nix profile)
    (import ./python.nix profile)
    (import ./markdown.nix profile)
  ];
}
