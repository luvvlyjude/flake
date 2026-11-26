{
  flake.nixosModules.theming = {
    xdg = {
      icons = {
        enable = true;
        fallbackCursorThemes = [ "Adwaita" ];
      };
    };
  };

  flake.homeModules.theming = {
    dconf.settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
