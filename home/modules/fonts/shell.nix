with import <nixpkgs> {};
  mkShell {
    packages = [
      fontforge
      nerd-font-patcher
    ];
  }
