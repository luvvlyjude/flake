{
  flake.nixosModules.zswap = {
    boot.zswap = {
      enable = true;
    };
  };
}
