{ self, ... }:
{
  flake.nixosModules.gaming = {
    imports = [
      self.nixosModules.gamemode
    ];
  };

  flake.homeModules.gaming = {
    imports = [
      self.homeModules.mangohud
    ];
  };
}
