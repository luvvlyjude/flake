{
  lib,
  pkgs,
  ...
}:

let
  # nix has no \u escape, so let JSON decode it
  glyph = code: builtins.fromJSON ''"\u${code}"'';

  gib = "w:3, p:Gi, hide_unit, pad_with:''";
  mbit = "w:1, prefix:M, unit:b";

  mouse =
    pkgs.writers.writePython3Bin "mouse"
      {
        libraries = [ pkgs.python3Packages.openrazer ];
      }
      ''
        import json

        from openrazer.client import DaemonNotFound, DeviceManager


        try:
            devices = DeviceManager().devices
        except DaemonNotFound:
            devices = []

        # empty text hides the block when the mouse is unplugged
        status = {"text": ""}
        for device in devices:
            if device.has("battery"):
                charging = device.is_charging
                status = {
                    "icon": "mouse_charging" if charging else "mouse",
                    "state": "Good" if charging else "Idle",
                    "text": f"{device.battery_level}%",
                }
                break

        print(json.dumps(status))
      '';
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
              disk_drive = glyph "f1c0"; # database
              gpu = glyph "f11b"; # gamepad
              memory_mem = glyph "f538"; # memory
              mouse = glyph "f8cc"; # computer-mouse
              mouse_charging = glyph "f0e7"; # bolt
            };
          };
        };
        blocks = [
          {
            block = "cpu";
            format = "$icon$utilization";
            interval = 3;
          }
          {
            block = "nvidia_gpu";
            format = lib.concatStrings [
              "$icon$utilization "
              "($vram_used.eng(${gib})/"
              "$vram_total.eng(${gib}))"
            ];
            interval = 3;
            # temps
            idle = 60;
            good = 75;
            info = 85;
            warning = 90;
          }
          {
            block = "memory";
            format = lib.concatStrings [
              "$icon"
              "$mem_used.eng(${gib})/"
              "$mem_total.eng(${gib})"
              # range hides values below 100 MiB, which would round to 0.0
              "{ ($zswap_compressed.eng(${gib}, range:100Mi..))|}"
            ];
          }
          {
            block = "memory";
            format = lib.concatStrings [
              "$icon_swap"
              "$swap_used.eng(${gib}, range:100Mi..)/"
              "$swap_total.eng(${gib}) "
              "($zswap_decompressed.eng(${gib})) |"
            ];
          }
          {
            block = "disk_space";
            format = lib.concatStrings [
              "$icon"
              "$used.eng(${gib})/"
              "$total.eng(${gib})"
            ];
          }
          {
            block = "net";
            format = lib.concatStrings [
              "$icon{$signal_strength | }"
              "^icon_net_down$speed_down.eng(${mbit}) "
              "^icon_net_up$speed_up.eng(${mbit})"
            ];
            interval = 3;
          }
          {
            block = "backlight";
            format = "$icon$brightness";
            # TODO: i kinda want a monitor emoji when missing
            # missing_format = "\\uf108";
            missing_format = "";
          }
          {
            block = "custom";
            command = lib.getExe mouse;
            format = "$icon$text";
            hide_when_empty = true;
            json = true;
            interval = 60;
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
