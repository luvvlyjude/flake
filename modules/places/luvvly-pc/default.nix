{ self, ... }:
{
  luvvly.places.luvvly-pc = {
    username = "jude";
    stateVersion = "26.05";
    system = "x86_64-linux";

    nixosModules = [
      self.nixosModules.luvvlyPcConfiguration
      self.nixosModules.luvvlyPcHardware
      self.nixosModules.core

      self.nixosModules.fans
      self.nixosModules.nvidia
      self.nixosModules.openrazer
      self.nixosModules.rgb

      self.nixosModules.packages
      self.nixosModules.zswap

      self.nixosModules.network

      self.nixosModules.desktop

      self.nixosModules.gaming
      self.nixosModules.minecraft

      self.nixosModules.development

      self.nixosModules.immich
      self.nixosModules.nh
      self.nixosModules.ydotool
    ];

    homeModules = [
      self.homeModules.desktop

      self.homeModules.gaming

      self.homeModules.development

      self.homeModules.bash
      self.homeModules.btop
      self.homeModules.discord
      self.homeModules.fastfetch
      self.homeModules.ncdu
      self.homeModules.ranger
      self.homeModules.spotifast
      self.homeModules.tree
      self.homeModules.zen
    ];
  };
}
