{ config, username, ... }:

{
  sops.secrets."passwords/${username}".neededForUsers = true;

  users = {
    mutableUsers = false;

    users = {
      root.hashedPassword = "!";

      "${username}" = {
        isNormalUser = true;
        uid = 1000;
        hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
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
    };
  };
}
