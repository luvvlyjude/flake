{
  flake.nixosModules.nh = { config, ... }: {
    programs.nh = {
      enable = true;

      flake = "${config.users.users.${config.luvvly.username}.home}/Projects/flake";
    };
  };
}
