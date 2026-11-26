{ self, ... }:
{
  flake.nixosModules.minecraft = {
    imports = [
      self.nixosModules.pamLimits
      self.nixosModules.tmpfsSymlink
      self.nixosModules.waywall
    ];

    home-manager.sharedModules = [ self.homeModules.minecraft ];
  };

  flake.homeModules.minecraft = {
    imports = [
      self.homeModules.modcheck
      self.homeModules.ninjabrainBot
      self.homeModules.prismlauncher
      self.homeModules.waywall
    ];
  };
}
