with import <nixpkgs> {};
  mkShell {
    packages = with pkgs; [
      win2xcur
    ];
  }
