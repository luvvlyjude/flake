{
  config,
  lib,
  pkgs,
  ...
}:

let
  # nix has no \u escape, so let JSON decode it
  glyph = code: builtins.fromJSON ''"\u${code}"'';

  # binary units with df-style labels, GB until 1000GB then TB
  # w counts the decimal point, so w:3 gives "3.8"
  size =
    value:
    let
      eng =
        prefix: args:
        "${value}.eng(${args}, p:${prefix}i, force_prefix:true, hide_prefix:true, hide_unit:true)${prefix}B";
    in
    "{${eng "G" "w:1, range:..1000Gi"}|${eng "T" "w:3"}}";

  vram = pkgs.writeShellApplication {
    name = "vram";
    runtimeInputs = [
      config.hardware.nvidia.package
      pkgs.gawk
    ];
    text = ''
      nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits \
        | awk -F', ' '{printf "%.1fGB/%.0fGB", $1/1024, $2/1024}'
    '';
  };
in
{
  hm.programs.i3status-rust = {
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
          icons = {
            icons = "awesome6";
            overrides = {
              cpu = glyph "f2db"; # microchip
              gpu = glyph "f11b"; # gamepad
              memory_mem = glyph "f538"; # memory
            };
          };
        };
        blocks = [
          {
            block = "net";
            format = "$icon{$signal_strength|100%} ^icon_net_down$speed_down.eng(w:1, prefix:M, unit:b) ^icon_net_up$speed_up.eng(w:1, prefix:M, unit:b)";
            interval = 3;
          }
          {
            block = "cpu";
            format = "$icon$utilization";
            interval = 3;
          }
          {
            block = "memory";
            format = "$icon${size "$mem_used"}/${size "$mem_total"}";
          }
          {
            block = "nvidia_gpu";
            format = "$icon$utilization";
            interval = 3;
            # colors follow temperature in °C, not load
            idle = 60;
            good = 75;
            info = 85;
            warning = 90;
          }
          {
            block = "custom";
            command = lib.getExe vram;
            format = "^icon_memory_mem$text";
            interval = 3;
          }
          {
            block = "disk_space";
            format = "$icon${size "$used"}/${size "$total"}";
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
