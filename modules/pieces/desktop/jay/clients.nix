{
  flake.homeModules.jay.wayland.windowManager.jay.settings = {

    clients = [
      {
        name = "capabilities nuke";
        match.all = [ ];
        capabilities = "all";
      }
    ];
  };
}
