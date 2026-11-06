{ pkgs, ... }:

let
  # luvvly-pc host age key: decrypts on switch and used by sops for edits
  luvvly-pc = "age1tgue6pmlg4j69h6kju5xkmjac4twpfkrfvxkwlkarrkz9hg5nd0q38rrwm";
in
{
  sops = {
    defaultSopsFile = ../../../../secrets/default.yaml;

    age = {
      keyFile = "/var/lib/sops/age/keys.txt";
      generateKey = true;
      sshKeyPaths = [ ];
    };
    gnupg.sshKeyPaths = [ ];
  };

  environment = {
    systemPackages = [
      pkgs.age
      pkgs.sops
    ];

    sessionVariables = {
      SOPS_AGE_KEY_FILE = "/var/lib/sops/age/keys.txt";
      SOPS_CONFIG = "/etc/sops/config.yaml";
    };

    # fixed path so open shells pick up rule changes after a rebuild
    etc."sops/config.yaml".source = (pkgs.formats.yaml_1_2 { }).generate "sops.yaml" {
      creation_rules = [
        {
          path_regex = "secrets/.*\\.yaml$";
          key_groups = [
            {
              age = [
                luvvly-pc
              ];
            }
          ];
        }
      ];
    };
  };
}
