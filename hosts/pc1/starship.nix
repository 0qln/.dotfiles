{ ... }: {
  #TODO: move this in the home config, as soon as the home manager options have the presets...
  programs.starship = {
    enable = true;
    presets = [
      "nerd-font-symbols"
      "catppuccin-powerline"
    ];
    settings = {
      cmd_duration = {
        disabled = true;
      };
    };
  };
}
