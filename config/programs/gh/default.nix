{
  home-manager.sharedModules = [
    {
      programs.gh = {
        enable = true;
        settings = {
          git_protocol = "ssh";
          spinner = "enabled";
        };
      };
    }
  ];
}
