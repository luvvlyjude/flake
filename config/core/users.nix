{ inputs, user, ... }:

{
  users = {
    # TODO: uncomment when declarative passwords are setup
    # mutableUsers = false;

    users = {
      "${user}" = {
        isNormalUser = true;
        uid = 1000;
        extraGroups = [
          "input"
          "gamemode"
          "networkmanager"
          "wheel"
          "ydotool"
        ];

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmea0rVQLhyQQ+5MDkrTsJ0gmEvEsc0+vlHdG+M7F9E jude@luvvly-laptop"
        ];
      };

      # TODO: disable root login
      # root = {
      #   hashedPassword = "!";
      #   initialHashedPassword = "!";
      # };
    };
  };

  # alias for home-manager.users.${user}
  # check ./default.nix
  hm = {
    home = {
      username = user;
      homeDirectory = "/home/${user}";
    };

    programs.home-manager.enable = true;

    home.stateVersion = "26.05";
  };
}
