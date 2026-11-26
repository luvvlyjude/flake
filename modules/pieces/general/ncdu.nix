{
  flake.homeModules.ncdu = { pkgs, ... }: {
    home.packages = [
      pkgs.ncdu
    ];
  };
}
