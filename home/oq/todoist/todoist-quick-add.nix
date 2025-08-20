{ pkgs, ... }:
let
  name = "todoist-quick-add";
  text = ''
    #!${pkgs.bash}/bin/bash
    read -p "Add a new task: " QUICK_ADD
    ${pkgs.todoist}/bin/todoist quick "$QUICK_ADD"
  '';
  script = pkgs.writeScriptBin name text;
in
pkgs.symlinkJoin {
  inherit name;
  paths = [
    script
  ]
  ++ (with pkgs; [
    bash
    todoist
  ]);
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
