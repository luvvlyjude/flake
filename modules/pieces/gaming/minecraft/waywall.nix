{ inputs, ... }:
{
  # pam-limits.nix next to this lets waywall request priority scheduling
  flake.nixosModules.waywall =
    { config, ... }:
    {
      users.users.${config.luvvly.username}.extraGroups = [ "input" ];
    };

  flake.homeModules.waywall = {
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
  };
}
