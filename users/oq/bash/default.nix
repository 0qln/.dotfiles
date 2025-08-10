{ ... }:
{

  programs.bash = {
    enable = true;
    # Setting session variables normally is broken when using home-manager ;(
    # context: https://github.com/nix-community/home-manager/issues/1011
    initExtra = ''
      export EDITOR="nvim"
      alias cdf='cd $(fd --hidden --type d | fzf)'
    '';
  };

}
