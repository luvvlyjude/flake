{
  programs.git = {
    enable = true;
  };

  home-manager.sharedModules = [
    {
      programs.git = {
        enable = true;

        settings = {
          init = {
            defaultBranch = "main";
          };

	  url = {
	    "git@github.com:".pushInsteadOf = "https://github.com/";
	  };

          user = {
            name = "jude";
            email = builtins.concatStringsSep "@" [
              "luvvlyjude"
              "gmail.com"
            ];
          };
        };

        signing = {
          format = "ssh";
          key = "~/.ssh/id_ed25519.pub";
          signByDefault = true;
        };
      };
    }
  ];
}
