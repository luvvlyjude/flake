{
  flake.nixosModules.users = { config, lib, ... }: {
    options.luvvly.username = lib.mkOption { type = lib.types.str; };

    config = {
      sops.secrets."passwords/${config.luvvly.username}".neededForUsers = true;

      users = {
        mutableUsers = false;

        users = {
          root.hashedPassword = "!";

          ${config.luvvly.username} = {
            isNormalUser = true;
            uid = 1000;
            hashedPasswordFile = config.sops.secrets."passwords/${config.luvvly.username}".path;

            extraGroups = [
              "wheel"
            ];

            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmea0rVQLhyQQ+5MDkrTsJ0gmEvEsc0+vlHdG+M7F9E jude@luvvly-laptop"
            ];
          };
        };
      };
    };
  };
}
