{ config, username, ... }:

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
      owner = username;
    };
  };

  hm.programs.git = {
    enable = true;

    includes = [ { inherit (config.sops.templates.git-identity) path; } ];

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
}
