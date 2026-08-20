{
  home-manager.sharedModules = [
    ({ pkgs, ... }: {
      home.packages = [
        pkgs.ncdu
      ];
    })
  ];
}
