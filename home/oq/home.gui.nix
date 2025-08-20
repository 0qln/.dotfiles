{ ... }:
{
  home-manager.users.oq =
    { ... }:
    {
      imports = [
        ./home._common.nix
        ./browsers
        ./cursors
        ./fonts
        ./hypr
        ./kitty
        ./nextcloud
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
