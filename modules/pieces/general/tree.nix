{
  flake.homeModules.tree = { pkgs, ... }: {
    home.packages = [
      pkgs.tree
    ];
  };
}
