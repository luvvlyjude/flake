{
  # config/core/pam-limits module allows waywall to request priority scheduling

  home-manager.sharedModules = [
    ({ inputs, ... }: {
      imports = [ inputs.mcsr-nixos.homeManagerModules.waywall ];

      programs.waywall = {
        enable = true;
        config = {
          # TODO: check out waywork, it looks rly good for config
          # enableWaywork = true;
          # TODO: use this stuff instead of home-manager linking
          # files = {
          # };
          # programs {
          # };
          source = ./waywall-config/init.lua;
        };
      };

      home.file = {
        ".config/waywall" = {
          source = ./waywall-config;
        };
      };
    })
  ];
}
