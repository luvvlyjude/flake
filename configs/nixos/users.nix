{ username, ... }:

{
  users = {
    # TODO: uncomment when declarative passwords are setup
    # mutableUsers = false;

    users = {
      "${username}" = {
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
}
