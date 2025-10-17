{
  description = "My dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-citrix.url = "nixpkgs/12bd230118a1901a4a5d393f9f56b6ad7e571d01";

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
    bongocat = {
      url = "github:0qln/wayland-bongocat";
    };

    # nixvim, does not follow global nixpkgs.
    nixvim.url = "github:nix-community/nixvim";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
    };
  };

  outputs = inputs @ {
    home-manager,
    sops-nix,
    nixvim,
    self,
    nixpkgs,
    nixpkgs-citrix,
    ...
  }: let
    inherit (nixpkgs) lib;
  in {
    # https://discourse.nixos.org/t/how-do-specialargs-work/50615/4
    # https://nixos-modules.nix.xn--q9jyb4c/lessons/function-arguments/lesson/

    nixosConfigurations."lif" = let
      system = "x86_64-linux";
      pkgs-citrix = import nixpkgs-citrix {
        inherit system;
        config = {
          allowUnfreePredicate = pkg:
            builtins.elem (lib.getName pkg) [
              "citrix-workspace"
            ];
          permittedInsecurePackages = [
            "libxml2-2.13.8"
            "libsoup-2.74.3"
          ];
        };
      };
    in
      lib.nixosSystem {
        inherit system;
        modules = [./hosts/lif];
        specialArgs = {
          inherit inputs;
          inherit pkgs-citrix;
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
