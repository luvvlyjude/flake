{
  flake.nixosModules.fonts = { pkgs, ... }: {
    fonts = {
      enableDefaultPackages = false;
      packages = with pkgs; [
        noto-fonts
        font-awesome
      ];
    };
  };
}
