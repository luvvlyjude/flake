{ inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  users = {
    # TODO: uncomment when declarative passwords are setup
    # mutableUsers = false;

    users = {
      jude = {
        isNormalUser = true;
        description = "Jude Love";
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

  home-manager = {
    # leaving out for now so that i'm warned on collisions
    # backupFileExtension = "hm-bak";
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;

    sharedModules = [
      # import all modules this flake exports (from modules/home-manager)
      inputs.self.homeManagerModules
    ];

    users.jude = {
      home.username = "jude";
      home.homeDirectory = "/home/jude";

      programs.home-manager.enable = true;

      home.stateVersion = "26.05";
    };
  };
}
