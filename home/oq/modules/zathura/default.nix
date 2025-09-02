{ pkgs, ... }:
{
  home.packages = with pkgs; [
    zathura
  ];

  home.file.".config/zathura/zathurarc" = {
    text = ''
      set recolor "true"
      set default-bg rgba(0,0,0,0.7)
      set recolor-lightcolor rgba(0,0,0,0)
      set adjust-open "width"
    '';
  };
}
