{
  hm = { pkgs, ... }: {
    home.packages = [
      pkgs.tree
    ];
  };
}
