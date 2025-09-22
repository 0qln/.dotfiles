let
  pkgs = import <nixpkgs> {};
in
  with pkgs;
    mkShell {
      packages = [
        (pkgs.python3.withPackages (python-pkgs:
          with python-pkgs; [
            requests
            icalendar
            beautifulsoup4
            lxml
          ]))
      ];
    }
