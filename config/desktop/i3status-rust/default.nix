{
  home-manager.sharedModules = [
    {
      programs.i3status-rust = {
        enable = true;

        bars = {
          jay = {
            settings = {
              theme = {
                theme = "plain";
                overrides = {
                  idle_fg = "#ffffff";
                  separator = "  ";
                  start_separator = "";
                };
              };
              icons.icons = "awesome6";
            };
            blocks = [
              {
                block = "net";
                format = "$icon{$signal_strength|100%} ^icon_net_down$speed_down.eng(w:1, prefix:M) ^icon_net_up$speed_up.eng(w:1, prefix:M)";
                interval = 1;
              }
              {
                block = "memory";
                format = "$icon$mem_used.eng(w:1, prefix:M)/$mem_total.eng(prefix:G)";
              }
              {
                block = "backlight";
                format = "$icon$brightness";
                # TODO: i kinda want a monitor emoji when missing
                # missing_format = "\\uf108";
                missing_format = "";
              }
              {
                block = "sound";
                format = "$icon$volume";
                show_volume_when_muted = true;
                headphones_indicator = true;
              }
              {
                block = "battery";
                format = "$icon$percentage";
                full_format = "$icon$percentage";
                missing_format = "";
              }
              {
                block = "time";
                format = "$icon $timestamp.datetime(f:'%A %B %-e %R')";
              }
            ];
          };
        };
      };
    }
  ];
}
