{
  lib,
  config,
  ...
}: let
  langs = config.modules.nixvim.wrapLangs;
in {
  programs.nixvim = {
    opts = {
      wrap = false;
    };
    extraConfigVim = let
      mkRule = lang:
      # vim
      ''
        autocmd FileType ${toString lang} setlocal wrap
      '';
      rules = map mkRule langs;
    in
      # vim
      ''
        augroup WrapLinePerFT
            autocmd!
            ${lib.strings.concatStrings rules}
        augroup END
      '';
  };
}
