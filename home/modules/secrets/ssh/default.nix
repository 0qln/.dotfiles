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
  utils,
  ...
}:
with lib; let
  cfg = config.modules.secrets.ssh;

  linkPair = name: method: let
    home = config.home.homeDirectory;
    inherit (config.sops) secrets;
  in [
    "L ${home}/.ssh/${name}/${method} - - - - ${secrets."sshKeys/${name}".path}"
    "L ${home}/.ssh/${name}/${method}.pub - - - - ${secrets."sshKeys/${name}.pub".path}"
  ];
in {
  options.modules.secrets.ssh = {
    enable = mkEnableOption "ssh secrets";

    #TODO: shell aliases as a seperate module and then this is not just bash specific.
    genBashAliases = utils.mkEnableOption "bash ssh-... aliases" config.modules.bash.enable;

    keyPairs = mkOption {
      type = types.attrs; # TODO: submodule
      default = [];
      description = "List of private/public key pairs";
      example = {
        "server" = {
          private = ./server/id_ed25519.enc;
          public = ./server/id_ed25519.pub;
          type = "ed25519";
        };
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

    # Link /run/secrets to ~/.ssh
    systemd.user.tmpfiles.rules =
      lists.flatten attrsets.mapAttrsToList (
        name: pair: (linkPair name "id_${pair.type}")
      )
      cfg.keyPairs;

    # Create shell aliases for ease of use
    programs.bash.initExtra = strings.concatLines (
      attrsets.mapAttrsToList (name: pair: ''
        alias ssh-${name}='ssh -i ~/.ssh/${name}/id_${pair.type}'
      '')
      cfg.keyPairs
    );
  };
}
