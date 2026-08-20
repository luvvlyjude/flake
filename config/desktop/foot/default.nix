{
  home-manager.sharedModules = [
    {
      home.sessionVariables.TERMINAL = "footclient";

      programs.foot = {
        enable = true;
        server.enable = true;

        settings = {
          main = {
            # font = "monospace:size=16,Noto Color Emoji:size=16";
            font = "monospace:size=16";
          };
          colors-dark = {
            background = "000000";
          };
        };
      };
    }
  ];
}
