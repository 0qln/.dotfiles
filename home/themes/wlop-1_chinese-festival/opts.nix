{lib, ...}: let
  name = builtins.dirOf __curPos.file;
in {
  options = with lib; {
    theme = {
      "enable_${name}" = mkEnableOption name;
    };
  };
}
