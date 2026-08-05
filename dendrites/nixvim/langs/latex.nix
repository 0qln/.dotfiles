{pkgs, ...}: {
  home.packages = with pkgs; [
  ];

  modules.nixvim.wrapLangs = ["tex"];

  programs.nixvim = {
    plugins = {
      vimtex = {
        enable = true;
        settings = {
          compiler_method = "generic";
          compiler_generic = let
            compiler = pkgs.writeShellScriptBin "latex-compiler" ''

              if [ -f "@tex" ]; then
                file="@tex"
              else
                file="main.tex"
              fi
              echo "Compiling tex file: $file"

              # latexmk integration docs: https://github.com/lervag/vimtex/blob/master/doc/vimtex.txt#L1019
              cmd_latex="latexmk -verbose \
                -file-line-error \
                -synctex=1 \
                -interaction=nonstopmode \
                -pvc \
                '$file' "

              cmd="$cmd_latex"

              echo "Executing: $cmd"

              if [ -f shell.nix ]; then
                shell="shell.nix"
                echo "Using shell: $shell"
                nix-shell "$shell" --command "$cmd"
              elif nix flake show --json | grep "devShells"; then
                flake="flake.nix"
                echo "Using flake: $flake"
                nix develop --command bash -c "$cmd"
              else
                exec "$cmd"
              fi
            '';
          in {
            command = ''${compiler}/bin/latex-compiler'';
          };
          view_method = "zathura";
          syntax_conceal = {
            "accents" = 1;
            "ligatures" = 1;
            "cites" = 1;
            "fancy" = 1;
            "spacing" = 1;
            "greek" = 1;
            "math_bounds" = 1;
            "math_delimiters" = 1;
            "math_fracs" = 1;
            "math_super_sub" = 1;
            "math_symbols" = 1;
            "sections" = 1;
            "styles" = 1;
          };
        };
      };
    };
  };
}
