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
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-citrix,
    nur,
    home-manager,
    ...
  }: let
    inherit (nixpkgs) lib;

    # todo: we are currently importing these inputs for all outputs, even though
    # not all of them need e.g. the citrix pinned pkgs. does this impact build times?
    # if so, fix it
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

    hm = rec {
      backupExtension = "hm-bac";

      config = system: {
        extraSpecialArgs = {
          inherit backupExtension;
          inherit inputs;
          pkgs-citrix = pkgs-citrix system;
        };
        backupFileExtension = backupExtension;
      };

      imports = [
        ./home/utils
        nur.modules.homeManager.default
      ];

      users = builtins.attrNames (builtins.readDir ./home/users);

      themes = builtins.filter (x: x == "directory") (
        builtins.attrNames (builtins.readDir ./home/themes)
      );

      envs = [
        "tui"
        "gui"
      ];
    };

    eachX = with lib;
      xs: fns:
        map (i: i.fn i.x) (
          attrsets.cartesianProduct {
            x = xs;
            fn = lists.flatten [fns];
          }
        );

    flake = self;
  in {
    homeConfigurations = let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system}.extend nur.overlays.default;
      config = hm.config system;
    in
      builtins.listToAttrs (
        pkgs.lib.lists.flatten (
          eachX hm.users (
            eachX hm.envs (
              eachX hm.themes (
                theme: env: user: let
                  vars = import ./home/users/${user}/vars.nix;
                in {
                  name = "${user}-${env}-${theme}";
                  value =
                    config
                    // home-manager.lib.homeManagerConfiguration {
                      inherit pkgs;
                      extraSpecialArgs =
                        config.extraSpecialArgs
                        // {
                          inherit flake;
                          inherit inputs;
                          inherit (pkgs) nur;
                        };
                      modules =
                        hm.imports
                        ++ [
                          (import ./home/users/${user}/home.nix)
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
                            home.homeDirectory = vars.home.directory;
                          })
                        ];
                    };
                }
              )
            )
          )
        )
      );

    nixosConfigurations = {
      # https://discourse.nixos.org/t/how-do-specialargs-work/50615/4
      # https://nixos-modules.nix.xn--q9jyb4c/lessons/function-arguments/lesson/

      "lif" = lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./hosts/lif
          (_: {
            home-manager =
              (hm.config system)
              // {
                users = builtins.listToAttrs (
                  eachX hm.users (user: {
                    name = user;
                    value = _: {inherit (hm) imports;};
                  })
                );
              };
          })
        ];
        specialArgs = {
          inherit inputs;
          flake = self;
          host-name = "lif";
          vars = import ./variables;
        };
      };

      "lifbrasir" = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./hosts/lifbrasir];
        specialArgs = {
          inherit inputs;
          flake = self;
          host-name = "lifbrasir";
        };
      };

      "loki" = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./hosts/loki];
        specialArgs = {
          inherit inputs;
          flake = self;
          host-name = "loki";
        };
      };

      "loki.lif" = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./hosts/loki.lif];
        specialArgs = {
          inherit inputs;
          flake = self;
          host-name = "loki-lif";
        };
      };

      "loki.gylfi" = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./hosts/loki.gylfi];
        specialArgs = {
          inherit inputs;
          flake = self;
          host-name = "loki-gylfi";
        };
      };
    };
  };
}
