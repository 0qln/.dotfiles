{
  description = "My dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nixpkgs-citrix.url = "nixpkgs/12bd230118a1901a4a5d393f9f56b6ad7e571d01";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    private = {
      url = "git+ssh://gitea@git.07112025.xyz/0qln/.private.git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        sops-nix.follows = "sops-nix";
      };
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
    bongocat = {
      url = "github:0qln/wayland-bongocat";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
    };

    nixvim.url = "github:nix-community/nixvim";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-citrix,
    nur,
    home-manager,
    ...
  }:
    with import ./utils; let
      inherit (nixpkgs) lib;

      utilz = (import-module ./utils/module.nix {inherit lib;}).utils;

      # this does not evaluate and thus not fetch unless pkgs-citrix is
      # being used in the respective output.
      # see https://discourse.nixos.org/t/nix-flake-inputs-not-lazy/25463/2
      pkgs-citrix = system:
        import nixpkgs-citrix {
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

      hm = {
        users = utilz.mods.collectMods ./home/users;
        themes = utilz.mods.collectMods ./home/themes;
        envs = user: (import ./home/users/${user}/envs.nix);
      };
      hosts = utilz.mods.collectMods ./hosts;

      nixosConfigurations = builtins.listToAttrs (
        utilz.mods.eachX hosts (
          utilz.mods.eachX hm.themes (
            theme: host: let
              systemPath = ./hosts/${host}/system.nix;
              system =
                if builtins.pathExists systemPath
                then (import systemPath)
                else "x86_64-linux";
            in {
              name = host;
              value = lib.nixosSystem rec {
                inherit system;
                modules = [./hosts/${host}];
                specialArgs = {
                  inherit utilz;
                  inherit inputs;
                  pkgs-citrix = pkgs-citrix system;
                  flake = self;
                  host-name = utilz.sanitizeHostName host;
                };
              };
            }
          )
        )
      );

      homeConfigurations = let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          inherit system;
          overlays = [nur.overlays.default];
        };
        vars = import ./vars {
          inherit (vars) config;
          inherit (pkgs) lib;
        };
      in
        builtins.listToAttrs (
          pkgs.lib.lists.flatten (
            # todo: add hosts info (e.g. lif.cachyos)
            utilz.mods.eachX hm.users (
              user:
                utilz.mods.eachX (hm.envs user) (
                  utilz.mods.eachX hm.themes (
                    theme: env: let
                      hm.config = import ./modules/home-manager/config.nix {
                        inherit utilz;
                        inherit inputs;
                        inherit (pkgs) nur;
                        pkgs-citrix = pkgs-citrix system;
                        config = vars;
                      };
                      hm.vars = import ./home/users/${user}/vars.nix {
                        inherit (hm.vars) config;
                        inherit (pkgs) lib;
                      };
                    in {
                      name = "${user}-${env}-${theme}";
                      value = home-manager.lib.homeManagerConfiguration (
                        hm.config
                        // {
                          inherit pkgs;
                          extraSpecialArgs = {
                            flake = self;
                            inherit inputs;
                            inherit (pkgs) nur;
                          };
                          modules = [
                            hm.vars
                            (import ./home/users/${user}/home.nix)
                            (import ./home/themes/${theme}/default.nix)
                            (_: {
                              settings = {
                                enable = pkgs.lib.mkDefault true;
                                uiEnv = pkgs.lib.mkDefault env;
                              };
                            })
                            (_: {
                              # Let Home Manager install and manage itself.
                              programs.home-manager.enable = true;

                              home.username = user;
                              home.homeDirectory = hm.vars.config.vars.root;
                            })
                          ];
                        }
                      );
                    }
                  )
                )
            )
          )
        );
    in {
      meta = {
        inherit hosts;
        hm = rec {
          inherit (hm) users themes;
          envs = builtins.listToAttrs (
            map (u: {
              name = u;
              value = hm.envs u;
            })
            users
          );
        };

        outputs = {
          nixosConfigurations = builtins.attrNames nixosConfigurations;
          homeConfigurations = builtins.attrNames homeConfigurations;
        };
      };

      inherit nixosConfigurations;
      inherit homeConfigurations;
    };
}
