{
  description = "My dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    inherit (nixpkgs) lib;
  in {
    # https://discourse.nixos.org/t/how-do-specialargs-work/50615/4
    # https://nixos-modules.nix.xn--q9jyb4c/lessons/function-arguments/lesson/

    nixosConfigurations."lif" = let
      system = "x86_64-linux";
    in
      lib.nixosSystem {
        inherit system;
        modules = [./hosts/lif];
        specialArgs = {
          inherit inputs;
          flake = self;
          host-name = "lif";
          vars = import ./variables;
        };
      };

    nixosConfigurations."lifbrasir" = lib.nixosSystem {
      system = "x86_64-linux";
      modules = [./hosts/lifbrasir];
      specialArgs = {
        inherit inputs;
        flake = self;
        host-name = "lifbrasir";
      };
    };

    nixosConfigurations."loki" = lib.nixosSystem {
      system = "x86_64-linux";
      modules = [./hosts/loki];
      specialArgs = {
        inherit inputs;
        flake = self;
        host-name = "loki";
      };
    };

    nixosConfigurations."loki.lif" = lib.nixosSystem {
      system = "x86_64-linux";
      modules = [./hosts/loki.lif];
      specialArgs = {
        inherit inputs;
        flake = self;
        host-name = "loki-lif";
      };
    };

    nixosConfigurations."loki.gylfi" = lib.nixosSystem {
      system = "x86_64-linux";
      modules = [./hosts/loki.gylfi];
      specialArgs = {
        inherit inputs;
        flake = self;
        host-name = "loki-gylfi";
      };
    };
  };
}
