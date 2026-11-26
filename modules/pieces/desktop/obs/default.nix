{
  flake.homeModules.obs =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      inherit (lib.generators) toINI;

      recordingsPath = config.home.homeDirectory + "/Videos/Recordings";
    in
    {
      programs.obs-studio = {
        enable = true;
        plugins = [
          pkgs.obs-studio-plugins.obs-pipewire-audio-capture
          pkgs.obs-studio-plugins.obs-shaderfilter
        ];
      };

      systemd.user.tmpfiles.rules = [ "d ${recordingsPath}" ];

      # default config values excluded
      xdg.configFile = lib.mapAttrs (_: file: file // { force = true; }) {
        "obs-studio/basic/scenes/Untitled.json".source = ./scenes.json;

        # stable path for scenes.json
        "obs-studio/shaders/fisheye.shader".source =
          "${pkgs.obs-studio-plugins.obs-shaderfilter}/share/obs/obs-plugins/obs-shaderfilter/examples/fisheye.shader";

        "obs-studio/user.ini".text = toINI { } {
          General.FirstRun = true;
          Appearance.Theme = "com.luvvly.Yami.Luvvly"; # ./theme.nix

          BasicWindow = {
            SysTrayEnabled = false;
            DocksLocked = true;
            # missing crashes the json parse
            ExtraBrowserDocks = "[]";
            # base64 Qt window/dock blobs
            geometry = "AdnQywADAAAAAAeAAAAAAAAADg8AAAP1AAAHgAAAAAAAAA4PAAAD9QAAAAEAAAAABpAAAAeAAAAAAAAADg8AAAP1";
            DockState = "AAAA/wAAAAD9AAAAAwAAAAAAAAJAAAADuvwCAAAAAfwAAAAaAAADugAAAZMA/////AEAAAAC/AAAAAAAAADUAAAAmAD////8AgAAAAL7AAAAFABzAGMAZQBuAGUAcwBEAG8AYwBrAQAAABoAAAO6AAAAjAD////8AAABqQAAAjgAAAAAAP////oAAAAAAQAAAAT7AAAAFgB0AHcAaQB0AGMAaABTAHQAYQB0AHMAAAAAAP////8AAAAAAAAAAPsAAAAUAHQAdwBpAHQAYwBoAEYAZQBlAGQAAAAAAP////8AAAAAAAAAAPsAAAAUAHQAdwBpAHQAYwBoAEkAbgBmAG8AAAAAAP////8AAAAAAAAAAPsAAAAUAHQAdwBpAHQAYwBoAEMAaABhAHQAAAAAAAAAAQMAAAAAAAAAAPwAAADYAAABaAAAAQIA/////AIAAAAC+wAAABYAcwBvAHUAcgBjAGUAcwBEAG8AYwBrAQAAABoAAAEyAAAAjAD////7AAAAEgBtAGkAeABlAHIARABvAGMAawEAAAFQAAAChAAAAQMA////AAAAAQAAAM4AAAPD/AIAAAAD+wAAABQAdAB3AGkAdABjAGgASQBuAGYAbwIAAA8yAAADWQAAASwAAAKK+wAAABYAdAB3AGkAdABjAGgAUwB0AGEAdABzAgAAEeQAAATpAAAAyAAAAPr7AAAAFAB0AHcAaQB0AGMAaABGAGUAZQBkAgAAD2QAAANZAAABLAAAAooAAAADAAAETAAAAQ78AQAAAAL7AAAAEgBzAHQAYQB0AHMARABvAGMAawEAAAJEAAACwgAAAqAA/////AAABQoAAAGGAAAAogD////6AAAAAQIAAAAC+wAAAB4AdAByAGEAbgBzAGkAdABpAG8AbgBzAEQAbwBjAGsBAAAAAP////8AAABjAP////sAAAAYAGMAbwBuAHQAcgBvAGwAcwBEAG8AYwBrAQAAAs0AAAEQAAAAtAD///8AAARMAAACqAAAAAEAAAACAAAAAQAAAAL8AAAAAA==";
          };
        };

        "obs-studio/basic/profiles/Untitled/basic.ini".text = toINI { } {
          Output.Mode = "Advanced";
          Stream1.IgnoreRecommended = true;

          Video = {
            BaseCX = 1920;
            BaseCY = 1080;
            OutputCX = 1920;
            OutputCY = 1080;
            FPSType = 1;
            FPSInt = 60;
          };

          AdvOut = {
            VodTrackEnabled = true;
            Encoder = "obs_nvenc_h264_tex";
            RecFilePath = recordingsPath;
            RecTracks = 62; # bitmask, tracks 2-6
            RecEncoder = "obs_nvenc_hevc_tex";

            Track1Name = "MC+Mic+Discord+Spotify";
            Track2Name = "MC+Mic+Discord";
            Track3Name = "Minecraft";
            Track4Name = "Mic";
            Track5Name = "Discord";
            Track6Name = "Spotify";

            Track1Bitrate = 320;
            Track2Bitrate = 320;
            Track3Bitrate = 320;
            Track4Bitrate = 320;
            Track5Bitrate = 320;
            Track6Bitrate = 320;
          };
        };

        "obs-studio/basic/profiles/Untitled/recordEncoder.json".text = builtins.toJSON {
          rate_control = "CQP";
          cqp = 18;
          keyint_sec = 2;
          preset = "p6";
          lookahead = false;
        };

        "obs-studio/basic/profiles/Untitled/streamEncoder.json".text = builtins.toJSON {
          rate_control = "CBR";
          bitrate = 7900;
          keyint_sec = 2;
          preset = "p6";
          lookahead = false;
        };
      };
    };
}
