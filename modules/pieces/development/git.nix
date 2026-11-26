{ self, ... }:
{
  flake.nixosModules.git =
    { config, ... }:
    {
      programs.git = {
        enable = true;
      };

      sops = {
        secrets."emails/online" = { };

        templates.git-identity = {
          content = ''
            [user]
              email = ${config.sops.placeholder."emails/online"}
          '';
          owner = config.luvvly.username;
        };
      };

      # home half needs the sops template above, so it comes with this module
      home-manager.sharedModules = [ self.homeModules.git ];
    };

  flake.homeModules.git =
    { osConfig, ... }:
    {
      programs.git = {
        enable = true;

        includes = [ { inherit (osConfig.sops.templates.git-identity) path; } ];

        settings = {
          init = {
            defaultBranch = "main";
          };

          url = {
            "git@github.com:".pushInsteadOf = "https://github.com/";
          };

          user.name = "jude";
        };

        ignores = [
          "**/.claude/*"
        ];

        signing = {
          format = "ssh";
          key = "~/.ssh/id_ed25519.pub";
          signByDefault = true;
        };
      };
    };
}
