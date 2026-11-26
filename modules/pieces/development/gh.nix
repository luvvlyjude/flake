{
  flake.homeModules.gh = {
    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        spinner = "enabled";
      };
    };
  };
}
