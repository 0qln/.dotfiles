{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.nixvim;
in {
  imports = [
    inputs.nixvim.homeModules.nixvim

    ./modules/keymap.nix
    ./modules/git.nix
    ./modules/treesitter.nix
    ./modules/completion.nix
    ./modules/formatting.nix
    ./modules/undo.nix
    ./modules/tmux.nix
    ./modules/remote.nix
    ./modules/linting.nix
    ./modules/file-management.nix
    ./modules/telescope.nix
    ./modules/qol.nix
    ./modules/dap.nix
    ./modules/trouble.nix
    ./modules/wayland.nix
    ./modules/system-clipboard.nix
    ./modules/clanker.nix

    ./langs/_all.nix

    ./appearance/colors.nix
    ./appearance/transparency.nix
    ./appearance/lualine.nix
    ./appearance/bufferline.nix
    ./appearance/icons.nix
    ./appearance/no-diagnostic-next-to-line-numbers.nix
    ./appearance/line-wrap.nix
    ./appearance/misc.nix
  ];

  options = with lib; {
    modules.nixvim = {
      enable = mkEnableOption "nixvim";
      wrapLangs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Languages for which to enable line wrapping.";
      };
      clanker.enable = mkEnableOption "clanker";
    };
  };

  config = lib.mkIf cfg.enable {
    # just in case i want to do it via copying my lua config again:
    # - https://github.com/Kidsan/nixos-config/blob/main/home/programs/neovim/nvim/lua/kidsan/set.lua
    # - https://github.com/samiulbasirfahim/flakes/blob/main/home/rxen/neovim/config/init.lua
    # - my example in utils.nix file.

    # docs:
    # inspiration:
    #   - https://github.com/LazyVim/LazyVim/blob/25abbf546d564dc484cf903804661ba12de45507/lua/lazyvim/plugins/ui.lua#L12
    #   - https://github.com/Ahwxorg/nixvim-config/blob/fe2f1c27fa532489800b8f4d17f12c13299afa8d/config/modules/plugins/lsp.nix#L6
    #   - https://github.com/bkp5190/Home-Manager-Configs/blob/main/plugins/default.nix
    #   - https://github.com/elythh/nixvim
    # nixvim options:
    #   - https://nix-community.github.io/nixvim/NeovimOptions/index.html

    # TODO: i want to do lazy loading some day:
    #   - https://github.com/nvim-neorocks/lz.n

    home.packages = with pkgs; [
      nodejs_24 # not sure anymore what depends on nodejs, could be treesitter but idk
    ];

    modules.nixvim.formatting.enable = mkDefault true;

    programs.nixvim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      defaultEditor = true;

      plugins = {
        #TODO: noice for toolwindows?
      };

      # misc options
      opts = {
        updatetime = 100;

        hidden = true;
        mouse = "a";
        mousemodel = "extend";
        splitbelow = true;
        splitright = true;

        incsearch = true;
        inccommand = "split";
        ignorecase = true;
        smartcase = true;

        tabstop = 4;
        shiftwidth = 4;
        expandtab = true;
        autoindent = true;
      };

      autoCmd = [
        {
          event = "InsertEnter";
          command = "norm zz<CR>";
        }
      ];
    };
  };
}
