{ ... }:
{
  home-manager.users.oq =
    { ... }:
    {
      imports = [
        ./home._common.nix
        ../../modules/browsers
        ../../modules/citrix
        ../../modules/cursors
        ../../modules/discord
        ../../modules/fonts
        ../../modules/hypr
        ../../modules/kitty
        ../../modules/nextcloud
        ../../modules/obsidian
        ../../modules/rofi
        ../../modules/secrets
        ../../modules/todoist
        ../../modules/youtube-music
        ../../modules/postman
        ../../modules/starship
        ../../modules/theme
        ../../modules/vscode
        ../../modules/repos
        ../../modules/splatmoji
        ../../modules/teams
        # ../../modules/wallpaper-engine
        ../../modules/rider
      ];
    };
}
