{pkgs}: let
  name = "cleaner";
  script = pkgs.writeShellScriptBin name (builtins.readFile ./cleaner.sh);
  packages = with pkgs; [];
in
  pkgs.symlinkJoin {
    inherit name;
    paths = [script] ++ packages;
    buildInputs = [pkgs.makeWrapper];
    postBuild = "wrapProgram $out/bin/${name} --prefix PATH : ${pkgs.lib.makeBinPath packages}";
  }
