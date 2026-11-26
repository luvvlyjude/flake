{ self, ... }:
{
  flake.nixosModules.network = {
    imports = [
      self.nixosModules.networkManager
      self.nixosModules.ssh
      self.nixosModules.tailscale
    ];
  };
}
