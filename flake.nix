{
  description = "My dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    # home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # sops-nix
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # zen browser
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.inputs.home-manager.follows = "home-manager";

    # hyprland
    hyprland.url = "github:hyprwm/hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprpaper.inputs.nixpkgs.follows = "nixpkgs";

    # nixvim, does not follow global nixpkgs.
    # Or does it? https://nix-community.github.io/nixvim/user-guide/install.html is
    # unclear about this
    # on unstable luajit tests are failing, so lets pin to stable 🐛
    nixvim.url = "github:nix-community/nixvim/nixos-25.05";
  };

  outputs =
    inputs@{
      home-manager,
      sops-nix,
      nixvim,
      self,
      nixpkgs,
      ...
    }:
    let
      lib = nixpkgs.lib;
    in
    {
      nixosConfigurations."pc1" = lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          inherit self;
          host-name = "pc1";
        };
        system = "x86_64-linux";
        modules = [
          ./hosts/_common/configuration.nix
          ./hosts/pc1/configuration.nix
          ./hosts/pc1/hardware-configuration.nix
        ];
      };
    };
}
