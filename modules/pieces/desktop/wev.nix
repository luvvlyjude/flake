{
  flake.homeModules.wev = { pkgs, ... }: {
    home.packages = [
      pkgs.wev
    ];
  };
}
