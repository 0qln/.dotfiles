{
  description = "My dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
    in
    {
      # https://discourse.nixos.org/t/how-do-specialargs-work/50615/4
      # https://nixos-modules.nix.xn--q9jyb4c/lessons/function-arguments/lesson/

      nixosConfigurations."lif" = lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/lif ];
        specialArgs = {
          inherit inputs;
          flake = self;
          host-name = "lif";
        };
      };

      nixosConfigurations."lifbrasir" = lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/lifbrasir ];
        specialArgs = {
          inherit inputs;
          flake = self;
          host-name = "lifbrasir";
        };
      };
    };
}
