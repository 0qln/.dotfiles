{
  description = "My dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ home-manager, self, nixpkgs, ... }:
  let
    lib = nixpkgs.lib;
  in {
    nixosConfigurations.pc1 = lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix

        # Include the results of the hardware scan.
        ./hosts/pc1/hardware-configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          #todo: move to own file
          home-manager.users.oq = { pkgs, ... }: {
            home.packages = with pkgs; [
              kdePackages.kate
              obsidian
              neovim
              git
              gh
            ];
            extraGroups = [ "networkmanager" "wheel" ];

            programs.firefox.enable = true;

            programs.git = {
              enable = true;
              userName  = "0qln";
              userEmail = "linusnag@gmail.com";
              extraConfig = {
                safe.directory = "/etc/nixos";
              };
            };

            # This value determines the NixOS release from which the default
            # settings for stateful data, like file locations and database versions
            # on your system were taken. It‘s perfectly fine and recommended to leave
            # this value at the release version of the first install of this system.
            # Before changing this value read the documentation for this option
            # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
            home.stateVersion = "25.05"; # Did you read the comment?
          };
        }
      ];
    };
  };
}
