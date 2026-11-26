{ self, ... }:
{
  flake.nixosModules.development = {
    imports = [
      self.nixosModules.git
    ];
  };

  flake.homeModules.development = {
    imports = [
      self.homeModules.ai
      self.homeModules.gh
      self.homeModules.neovim
      self.homeModules.vscodium
      self.homeModules.zed
    ];
  };
}
