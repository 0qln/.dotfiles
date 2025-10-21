{pkgs}: let
  name = "lf-ueberzug";
  script = pkgs.writeShellScriptBin name (builtins.readFile ./lf-ueberzug.sh);
in
  pkgs.symlinkJoin {
    inherit name;
    paths = [
      script
      pkgs.ueberzugpp
    ];
    buildInputs = [pkgs.makeWrapper];
    postBuild = "wrapProgram $out/bin/${name} --prefix PATH : ${
      pkgs.lib.makeBinPath [pkgs.ueberzugpp]
    }";
  }
