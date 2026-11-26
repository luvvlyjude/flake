{ inputs, self, ... }:
{
  imports = [
    inputs.home-manager.flakeModules.default
  ];

  flake.nixosModules.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      sharedModules = [ self.homeModules.default ];
    };
  };

  flake.homeModules.default = { osConfig, ... }: {
    home.stateVersion = osConfig.system.stateVersion;
  };
}
