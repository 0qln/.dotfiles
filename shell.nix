with import <nixpkgs> {};
  mkShell {
    name = "dotfiles";

    packages = [
      alejandra
      fd
      sops
    ];

    shellHook = ''
      alias update-sops-keys="fd -t f -H . | grep .*secrets.* | xargs sops updatekeys -y"
    '';
  }
