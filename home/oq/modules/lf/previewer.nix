{ pkgs }:
let
  name = "previewer";
  script = pkgs.writeShellScriptBin name (builtins.readFile ./previewer.sh);
  packages = with pkgs; [
    ueberzugpp
  ];
in
pkgs.symlinkJoin {
  inherit name;
  paths = [ script ] ++ packages;
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : ${pkgs.lib.makeBinPath packages}";
}
