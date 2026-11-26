{ self, ... }:
{
  flake.nixosModules.core = {
    imports = [
      self.nixosModules.home-manager
      self.nixosModules.limine
      self.nixosModules.localization
      self.nixosModules.nix
      self.nixosModules.tty
      self.nixosModules.privates
      self.nixosModules.users
    ];

    boot.tmp.cleanOnBoot = true;

    documentation = {
      doc.enable = false;
      info.enable = false;
      nixos.enable = false;
    };
  };
}
