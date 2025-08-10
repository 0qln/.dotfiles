{ name, pkgs, servicePkgs ? [] }:

let
  script = (pkgs.writeScriptBin name (builtins.readFile ./session.sh)).overrideAttrs(old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
in pkgs.symlinkJoin {
  inherit name;
  paths = [ script ] ++ servicePkgs;
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
