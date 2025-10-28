#>
#> Todo: is the comment below still true?
#>
#> Note:
#> This breaks for the root user.
#> I don't know why but it just does and then systemd fails
#> to find the sops-nix.service because idkklklj;lkjasd;lfkjalkfj
#>
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.secrets.ssh;

  linkPair = name: let
    inherit (config.sops) secrets;
  in [
    "L ${cfg.identities.${name}} - - - - ${secrets."sshKeys/${name}".path}"
    "L ${cfg.identities.${name}}.pub - - - - ${secrets."sshKeys/${name}.pub".path}"
  ];

  keyPairType = types.submodule {
    options = {
      private = mkOption {
        type = types.path;
        description = "Path to the encrypted private key file";
      };
      public = mkOption {
        type = types.path;
        description = "Path to the encrypted public key file";
      };
      type = mkOption {
        type = types.str;
        description = "SSH key type (e.g., ed25519, rsa, ecdsa)";
        example = "ed25519";
      };
    };
  };
  # apparently u can use submodule like this, see
  # https://github.com/nix-community/home-manager/blob/release-25.05/modules/programs/rofi.nix
  # for more on this :)
  #
  # identityType =
  #   types.submodule {
  #     options = {
  #       _type = mkOption {
  #         type = types.enum (builtins.attrNames cfg.keyPairs);
  #         internal = true;
  #       };
  #       value = mkOption {
  #         type = types.str;
  #         internal = true;
  #       };
  #     };
  #   }
  #   // {
  #     description = "The path on the system where the ssh secret will life.";
  #   };
  #
  # Note: using this as an implementation for my identityType here is bullscheiße, but it's neat
  # that you can annotate types for internal usage like this :)
  #
in {
  options.modules.secrets.ssh = {
    enable = mkEnableOption "ssh secrets";

    #TODO: shell aliases as a seperate module and then this is not just bash specific.
    genBashAliases = config.utils.mkEnableOption "bash ssh-... aliases" config.modules.bash.enable;

    keyPairs = mkOption {
      type = types.attrsOf keyPairType;
      default = {};
      description = "List of private/public key pairs";
      example = {
        "server" = {
          private = ./server/id_ed25519.enc;
          public = ./server/id_ed25519.pub;
          type = "ed25519";
        };
      };
    };

    identities = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "The path on the system where each secret will life";
      example = {
        "server" = "${config.home.homeDirectory}/.ssh/server/id_ed25519";
      };
    };
  };

  config = mkIf cfg.enable {
    # Register as sops secrets with correct permissions
    sops.secrets = attrsets.mergeAttrsList (
      attrsets.mapAttrsToList (name: pair: {
        "sshKeys/${name}" = {
          format = "binary";
          sopsFile = pair.private;
          mode = "0600";
        };
        "sshKeys/${name}.pub" = {
          format = "binary";
          sopsFile = pair.public;
          mode = "0644";
        };
      })
      cfg.keyPairs
    );

    # ssh secret paths
    modules.secrets.ssh.identities = let
      home = config.home.homeDirectory;
    in
      attrsets.mapAttrs (name: pair: mkDefault "${home}/.ssh/${name}/id_${pair.type}")
      cfg.keyPairs;

    # Link /run/secrets to ~/.ssh
    systemd.user.tmpfiles.rules = lists.flatten (
      attrsets.mapAttrsToList (name: _pair: (linkPair name)) cfg.keyPairs
    );

    # Create shell aliases for ease of use
    programs.bash.initExtra = strings.concatLines (
      attrsets.mapAttrsToList (name: _pair: ''
        alias ssh-${name}='ssh -i ${cfg.identities.${name}}'
      '')
      cfg.keyPairs
    );
  };
}
