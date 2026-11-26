{ self, ... }:
{
  flake.nixosModules.desktop = {
    imports = [
      self.nixosModules.audio
      self.nixosModules.fonts
      self.nixosModules.greetd
      self.nixosModules.jay
      self.nixosModules.oo7
      self.nixosModules.printing
      self.nixosModules.theming
    ];
  };

  flake.homeModules.desktop = {
    imports = [
      self.homeModules.foot
      self.homeModules.fuzzel
      self.homeModules.i3statusRust
      self.homeModules.idle
      self.homeModules.imv
      self.homeModules.jay
      self.homeModules.mpv
      self.homeModules.obs
      self.homeModules.satty
      self.homeModules.swaync
      self.homeModules.theming
      self.homeModules.vlc
      self.homeModules.wev
      self.homeModules.xdg
    ];
  };
}
