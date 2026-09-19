{
  xdg = {
    icons = {
      enable = true;
      fallbackCursorThemes = [ "Adwaita" ];
    };
  };

  hm.imports = [
    {
      dconf.settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    }
  ];
}
