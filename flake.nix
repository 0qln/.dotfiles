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
      url = "git+ssh://git@github.com/0qln/.private.git";
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
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-citrix,
    nur,
    home-manager,
    nixvim,
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

    sanitizeHostName = name: builtins.replaceStrings ["."] ["-"] (lib.strings.sanitizeDerivationName name);

    isHidden = file: builtins.match "_.*" file != null;
    isDir = type: type == "directory";
    isX = f: t: (isDir t) && !(isHidden f);
    collectXs = xDir: builtins.attrNames (lib.attrsets.filterAttrs isX (builtins.readDir xDir));
    eachX = with lib;
      xs: fns:
        map (i: i.fn i.x) (
          attrsets.cartesianProduct {
            x = xs;
            fn = lists.flatten [fns];
          }
        );

    hm = {
      users = collectXs ./home/users;

      themes = collectXs ./home/themes;

      envs = user: (import ./home/users/${user}/envs.nix);
    };

    hosts = collectXs ./hosts;
  in {
    nixosConfigurations = builtins.listToAttrs (
      eachX hosts (
        host: let
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
              inherit inputs;
              #TODO: how to not import pkgs-citrix for outputs that don't need this input?
              pkgs-citrix = pkgs-citrix system;
              flake = self;
              host-name = sanitizeHostName host;
            };
          };
        }
      )
    );

    homeConfigurations = let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [nur.overlays.default];
      };
      vars = import ./variables {
        inherit (vars) config;
        inherit (pkgs) lib;
      };
    in
      builtins.listToAttrs (
        pkgs.lib.lists.flatten (
          # todo: add hosts (e.g. lif.cachyos)
          eachX hm.users (
            user:
              eachX (hm.envs user) (
                eachX hm.themes (
                  theme: env: let
                    hm.config = import ./modules/home-manager/config.nix {
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
  };
}
