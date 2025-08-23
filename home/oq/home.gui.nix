{ ... }:
{
  home-manager.users.oq =
    { ... }:
    {
      imports = [
        ./home._common.nix
        ./browsers
        ./citrix
        ./cursors
        ./discord
        ./fonts
        ./hypr
        ./kitty
        ./nextcloud
        ./obsidian
        ./rofi
        ./secrets
        ./todoist
        ./youtube-music
        ./postman
        ./starship
        ./theme
        ./vscode
        ./repos
        ./splatmoji
        ./wallpaper-engine
      ];
    };
}
