{ pkgs, ... }:

{
  home.packages = [ pkgs.spotifast ];

  xdg.configFile."spotifast/themes/luvvly.json".text = builtins.toJSON {
    base = "dark";
    colors = {
      window = "#000000";
      panel = "#000000";
      surface = "#000000";
      surface_hover = "#140010";
      surface_active = "#250015";
      outline = "#350030";
      text = "#EEEEEE";
      secondary = "#999999";
      dim = "#5A3355";
      accent = "#8A007A";
      accent_hover = "#B0209E";
      on_accent = "#EEEEEE";
    };
  };
}
