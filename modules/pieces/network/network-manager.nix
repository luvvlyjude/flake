{
  flake.nixosModules.networkManager = { config, ... }: {
    networking.networkmanager.enable = true;

    users.users.${config.luvvly.username}.extraGroups = [ "networkmanager" ];
  };
}
