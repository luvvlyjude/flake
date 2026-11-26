{
  flake.nixosModules.ydotool = { config, ... }: {
    # programs.ydotool doesn't load the uinput kernel module
    hardware.uinput.enable = true;

    programs.ydotool = {
      enable = true;
    };

    users.users.${config.luvvly.username}.extraGroups = [ "ydotool" ];
  };
}
