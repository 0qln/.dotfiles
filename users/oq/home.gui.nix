{ ... }:
{
  home-manager.users.oq =
    { ... }:
    {
      imports = [
        ./home._common.nix
        ./browsers
        ./fonts
        ./hypr
        ./kitty
        ./obsidian
        ./rofi
        ./secrets
        ./todoist
        ./youtube-music
        ./starship
        ./theme
      ];
    };
}
