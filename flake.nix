{
  description = "My dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "nixpkgs/nixos-25.05";

    nixpkgs-hot.url = "nixpkgs/nixos-unstable";

    nixpkgs-citrix.url = "nixpkgs/12bd230118a1901a4a5d393f9f56b6ad7e571d01";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

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
    cartograph-cf = {
      url = "github:0qln/Cartograph";
      inputs.nixpkgs.follows = "nixpkgs";
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
    nur,
    flake-parts,
    home-manager,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} ({
      config,
      withSystem,
      ...
    }:
      with import ./utils; let
        inherit (inputs.nixpkgs) lib;

        utilz = (import-module ./utils/module.nix {inherit lib;}).utils;

        hosts = utilz.mods.collectMods ./hosts;

        hm = {
          users = utilz.mods.collectMods ./home/users;
          themes = utilz.mods.collectMods ./home/themes;
          envs = user: (import ./home/users/${user}/envs.nix);
        };
      in {
        systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
        imports = [];
        perSystem = {
          pkgs,
          lib,
          ...
        }: let
        in {
          devShells.default = with pkgs;
          with (import ./utils); let
            inherit (import-module ./vars {inherit pkgs;}) vars;
            lifbrasir = vars.hosts.lifbrasir.fqdns.primary.dn;

            var-ensure = key: val:
            # bash
            ''[ -z "''$${key}" ] && export ${key}="${val}"'';
          in
            pkgs.mkShell {
              name = "dotfiles";
              packages = [
                alejandra
                fd
                sops
                age-plugin-yubikey
              ];

              shellHook =
                # bash
                ''
                  ${var-ensure "lifbrasir" lifbrasir}
                  ${var-ensure "HM_BACKUP_EXT" vars.home.config.backup.extension}
                  export PATH="$PWD/bin:$PATH"
                '';
            };
        };

        flake = let
          getSystem = host: let
            fallback = (import-module ./vars {pkgs = {};}).vars.system.default;
            systemPath = ./hosts/${host}/system.nix;
          in
            if builtins.pathExists systemPath
            then (import systemPath)
            else fallback;

          pkgss = system: {
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                inputs.nur.overlays.default
                inputs.cartograph-cf.overlays.default
              ];
            };

            # this does not evaluate and thus not fetch unless pkgs-citrix is
            # being used in the respective output.
            # see https://discourse.nixos.org/t/nix-flake-inputs-not-lazy/25463/2
            pkgs-citrix = import inputs.nixpkgs-citrix {
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

            pkgs-stable = import inputs.nixpkgs-stable {
              inherit system;
            };

            pkgs-hot = import inputs.nixpkgs-hot {
              inherit system;
            };
          };

          nixosConfigurations = builtins.listToAttrs (
            utilz.mods.eachX hosts (
              host: let
                system = getSystem host;
                inherit (pkgss system) pkgs-citrix pkgs-stable pkgs-hot pkgs;
              in {
                name = host;
                value = withSystem system (_:
                  inputs.nixpkgs.lib.nixosSystem {
                    inherit pkgs;
                    modules = [./hosts/${host}];
                    specialArgs = {
                      inherit utilz;
                      inherit inputs;
                      inherit pkgs-citrix;
                      inherit pkgs-stable;
                      inherit pkgs-hot;
                      flake = self;
                      host-name = utilz.sanitizeHostName host;
                    };
                  });
              }
            )
          );

          homeConfigurations = builtins.listToAttrs (
            lib.lists.flatten (
              utilz.mods.eachX hosts (
                host: let
                  system = getSystem host;
                  inherit (pkgss system) pkgs-citrix pkgs-stable pkgs-hot pkgs;
                  vars = import-module ./vars {inherit pkgs;};
                in
                  utilz.mods.eachX hm.users (
                    user:
                      utilz.mods.eachX (hm.envs user) (
                        utilz.mods.eachX hm.themes (
                          theme: env: let
                            hm.config = import ./modules/home-manager/config.nix {
                              inherit utilz;
                              inherit inputs;
                              inherit (pkgs) nur;
                              inherit pkgs;
                              inherit pkgs-hot;
                              inherit pkgs-citrix;
                              inherit pkgs-stable;
                              config = vars;
                              flake = self;
                            };
                            hm.vars = import ./home/users/${user}/vars.nix {
                              inherit (hm.vars) config;
                              inherit lib;
                            };
                          in {
                            name = "${user}-${host}-${env}-${theme}";
                            value = withSystem (system host) (_:
                              home-manager.lib.homeManagerConfiguration (
                                hm.config
                                // {
                                  pkgs = (pkgss system).pkgs;
                                  modules = [
                                    hm.vars
                                    (import ./home/users/${user}/home.nix)
                                    (import ./hosts/${host}/home-vars.nix)
                                    (_: {
                                      settings = {
                                        enable = lib.mkDefault true;
                                        uiEnv = lib.mkDefault env;
                                      };
                                      themes = {
                                        ${theme}.enable = true;
                                      };
                                    })
                                    (_: {
                                      # Let Home Manager install and manage itself.
                                      programs.home-manager.enable = true;

                                      nix.package = pkgs.nix;

                                      home.username = user;
                                      home.homeDirectory = hm.vars.config.vars.root;
                                    })
                                  ];
                                }
                              ));
                          }
                        )
                      )
                  )
              )
            )
          );
        in {
          inherit nixosConfigurations;
          inherit homeConfigurations;

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
        };
      });
}
