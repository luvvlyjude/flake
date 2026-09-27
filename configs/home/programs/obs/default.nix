{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.generators) toINI;

  mapForced = lib.mapAttrs (
    _: text: {
      inherit text;
      force = true;
    }
  );

  mkEncoder =
    attrs:
    builtins.toJSON (
      {
        keyint_sec = 2;
        preset = "p6";
        lookahead = false;
      }
      // attrs
    );

  mkVideo =
    {
      width,
      height,
      fps,
    }:
    {
      BaseCX = width;
      BaseCY = height;
      OutputCX = width;
      OutputCY = height;
      FPSType = 1;
      FPSInt = fps;
    };

  mkTracks =
    names:
    lib.mergeAttrsList (
      lib.imap1 (i: name: {
        "Track${toString i}Name" = name;
        "Track${toString i}Bitrate" = 320;
      }) names
    );

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

  # defaults excluded and diff.sh ignores defaults too
  xdg.configFile = mapForced {
    # "Untitled" is OBS's default profile and collection name
    "obs-studio/basic/scenes/Untitled.json" = builtins.toJSON (import ./scenes.nix { inherit pkgs; });

    "obs-studio/basic/profiles/Untitled/recordEncoder.json" = mkEncoder {
      rate_control = "CQP";
      cqp = 18;
    };

    "obs-studio/basic/profiles/Untitled/streamEncoder.json" = mkEncoder {
      rate_control = "CBR";
      bitrate = 7900;
    };

    "obs-studio/themes/Luvvly.ovt" = import ./theme.nix { inherit lib; };

    "obs-studio/user.ini" = toINI { } {
      General.FirstRun = true;
      Appearance.Theme = "com.luvvly.Yami.Luvvly";

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

    "obs-studio/basic/profiles/Untitled/basic.ini" = toINI { } {
      Output.Mode = "Advanced";
      Stream1.IgnoreRecommended = true;

      Video = mkVideo {
        width = 1920;
        height = 1080;
        fps = 60;
      };

      AdvOut = {
        VodTrackEnabled = true;
        Encoder = "obs_nvenc_h264_tex";
        RecFilePath = recordingsPath;
        RecTracks = 62; # bitmask, tracks 2-6
        RecEncoder = "obs_nvenc_hevc_tex";
      }
      # order matters
      // mkTracks [
        "MC+Mic+Discord+Spotify" # 1
        "MC+Mic+Discord" # 2
        "Minecraft" # 3
        "Mic" # 4
        "Discord" # 5
        "Spotify" # 6
      ];
    };
  };
}
