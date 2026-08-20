{
  home-manager.sharedModules = [
    ({ pkgs, ... }: {
      home.packages = [
        pkgs.tree
      ];
    })
  ];
}
