{
  description = "My dotfiles";

  inputs = {
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    nixpkgs.url = "nixpkgs/nixos-unstable";

    nixpkgs-server.url = "nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "nixpkgs/nixos-25.05";

    nixpkgs-hot.url = "nixpkgs/nixos-unstable";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
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
    nixvim = {
      url = "github:nix-community/nixvim";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nephrid = {
      url = "github:0qln/Nephrid";
    };
  };

  outputs = inputs @ {
    self,
    nur,
    flake-parts,
    home-manager,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} ({withSystem, ...}: let
      inherit (inputs.nixpkgs) lib;

      # todo: maybe if needed use flake-parts.lib.mkFlake here
      evalDendrite = {
        path,
        attrPath,
        specialArgs ? {},
      }: let
        dendrite = import path {inherit inputs;};
        module = lib.attrByPath attrPath {} dendrite;
      in
        lib.evalModules {
          modules = [module];
          inherit specialArgs;
        };

      utilz =
        (evalDendrite {
          path = ./dendrites/utils;
          attrPath = ["flake" "nixosModules" "utils"];
        }).config.utils;

      vars = pkgs:
        (evalDendrite {
          path = ./dendrites/vars;
          attrPath = ["flake" "nixosModules" "vars"];
          specialArgs = {inherit pkgs;};
        }).config.vars;

      hosts = utilz.mods.collectMods ./hosts;

      profiles = (utilz.mods.collectMods ./profiles) ++ [""];

      hm = {
        users = utilz.mods.collectMods ./home/users;
        themes = utilz.mods.collectMods ./home/themes;
        envs = user: (import ./home/users/${user}/envs.nix);
      };

      pkgss = system: {
        pkgs = import inputs.nixpkgs {inherit system;};
        pkgs-server = import inputs.nixpkgs-server {inherit system;};
        pkgs-stable = import inputs.nixpkgs-stable {inherit system;};
        pkgs-hot = import inputs.nixpkgs-hot {inherit system;};
      };

      mkHostArgs = host: system: let
        inherit (pkgss system) pkgs-stable pkgs-server pkgs-hot;
      in {
        # todo: utilz shouldn't be needed here anymore
        inherit utilz;
        inherit inputs;
        inherit pkgs-stable;
        inherit pkgs-server;
        inherit pkgs-hot;
        flake = self;
        host-name = utilz.sanitizeHostName host;
      };

      nixosOptsModules = lib.attrValues (
        lib.filterAttrs (n: _: lib.hasSuffix "-opts" n) self.nixosModules
      );

      homeOptsModules = lib.attrValues (
        lib.filterAttrs (n: _: lib.hasSuffix "-opts" n) self.homeModules
      );

      mkNixosSystem = host: system: extraModules:
        withSystem system (_:
          inputs.nixpkgs.lib.nixosSystem {
            specialArgs = mkHostArgs host system;
            modules =
              extraModules
              ++ nixosOptsModules
              ++ [
                {
                  home-manager.users = lib.genAttrs hm.users (_: {
                    imports = homeOptsModules;
                  });
                }
              ];
          });
    in {
      options = {
        flake.homeModules = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.unspecified;
          default = {};
          description = "Home Manager modules exported by the flake.";
        };
      };

      imports = let
        isDirectory = f: t: t == "directory";

        hasDefaultNix = dir: f: t: (
          builtins.readDir ./${dir}/${f}
          |> builtins.hasAttr "default.nix"
        );

        hasOptsNix = dir: f: t: (
          builtins.readDir ./${dir}/${f}
          |> builtins.hasAttr "opts.nix"
        );

        collectDendrites = dir:
          builtins.readDir ./${dir}
          |> inputs.nixpkgs.lib.attrsets.filterAttrs isDirectory
          |> inputs.nixpkgs.lib.attrsets.filterAttrs (hasDefaultNix dir)
          |> builtins.attrNames
          |> builtins.map (x: ./${dir}/${x});

        collectOptsNix = dir:
          builtins.readDir ./${dir}
          |> inputs.nixpkgs.lib.attrsets.filterAttrs isDirectory
          |> inputs.nixpkgs.lib.attrsets.filterAttrs (hasOptsNix dir)
          |> builtins.attrNames
          |> builtins.map (x: ./${dir}/${x}/opts.nix);
      in
        [hosts/${"lif?dendrite"}/default.nix]
        ++ (collectDendrites "dendrites")
        ++ (collectDendrites "dendrites/themes")
        ++ (collectOptsNix "dendrites")
        ++ (collectOptsNix "dendrites/themes");

      config = {
        _module.args = {inherit mkHostArgs mkNixosSystem;};

        systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

        perSystem = {pkgs, ...}: {
          devShells.default = with pkgs; let
            lifbrasir = (vars pkgs).hosts.lifbrasir.fqdns.primary.dn;

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
                  ${var-ensure "HM_BACKUP_EXT" (vars pkgs).home.config.backup.extension}
                  export PATH="$PWD/bin:$PATH"
                '';
            };
        };

        flake = let
          getSystem = host: let
            fallback = (vars {}).system;
            systemPath = ./hosts/${host}/system.nix;
          in
            if builtins.pathExists systemPath
            then (import systemPath)
            else fallback;

          nixosConfigurations = builtins.listToAttrs (
            utilz.mods.eachX hosts (
              host: let
                system = getSystem host;
              in {
                name = host;
                value = mkNixosSystem host system [./hosts/${host}];
              }
            )
          );

          # `profile` is option
          mkHomeName = {
            user,
            host,
            env,
            theme,
            profile,
          }:
            "${user}-${host}-${env}-${theme}"
            + (
              if profile != ""
              then "-${profile}"
              else ""
            );

          homeConfigurations = builtins.listToAttrs (
            lib.lists.flatten (
              utilz.mods.eachX hosts (
                host: let
                  system = getSystem host;
                  inherit (pkgss system) pkgs-stable pkgs-hot pkgs;
                in
                  utilz.mods.eachX hm.users (
                    user:
                      utilz.mods.eachX (hm.envs user) (
                        utilz.mods.eachX hm.themes (
                          utilz.mods.eachX profiles (
                            profile: theme: env: let
                              hm.config = import ./modules/home-manager/config.nix {
                                inherit utilz;
                                inherit inputs;
                                inherit (pkgs) nur;
                                inherit pkgs;
                                inherit pkgs-hot;
                                inherit pkgs-stable;
                                config = vars {};
                                flake = self;
                              };
                            in {
                              name = mkHomeName {inherit user host env theme profile;};
                              value = withSystem (system host) (_:
                                home-manager.lib.homeManagerConfiguration (
                                  hm.config
                                  // {
                                    pkgs = (pkgss system).pkgs;
                                    modules =
                                      [
                                        (import ./home/users/${user}/home.nix)
                                        (import ./hosts/${host}/home-vars.nix)
                                        # (import ./profiles/${profile}/home.nix)
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
                                        })
                                      ]
                                      ++ homeOptsModules;
                                  }
                                ));
                            }
                          )
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
      };
    });
}
