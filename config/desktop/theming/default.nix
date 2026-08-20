{
  xdg = {
    icons = {
      enable = true;
      fallbackCursorThemes = [ "Adwaita" ];
    };
  };

  home-manager.sharedModules = [
    {
      dconf.settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    }
  ];
}
