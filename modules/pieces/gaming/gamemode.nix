{
  flake.nixosModules.gamemode = { config, ... }: {
    programs.gamemode = {
      enable = true;

      settings = {
        general = {
          renice = 5;
        };
      };
    };

    users.users.${config.luvvly.username}.extraGroups = [ "gamemode" ];
  };
}
