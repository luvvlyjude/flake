{ pkgs }:

let
  # without prev_ver libobs treats sources as pre-23.2.2 and resets monitoring/mixers,
  # any newer value behaves the same. id is the versioned one (e.g. text_ft2_source_v2)
  source =
    id: name: attrs:
    {
      inherit id name;
      prev_ver = 536936450; # 32.1.2
    }
    // attrs;

  # scene items load visible = false and scale = 0 when unset,
  # and a missing pos gets converted from pixels twice (lands at -2,-1)
  item =
    name: attrs:
    {
      inherit name;
      visible = true;
      pos = {
        x = 0.0;
        y = 0.0;
      };
      scale = {
        x = 1.0;
        y = 1.0;
      };
    }
    // attrs;

  appAudio =
    name: target: mixers: volume:
    source "pipewire_audio_application_capture" name {
      settings.TargetName = target;
      inherit mixers volume;
    };
in
{
  version = 2;
  current_scene = "Main";
  current_program_scene = "Main";
  current_transition = "Cut";
  preview_locked = true;
  scene_order = [
    { name = "Main"; }
    { name = "Audio"; }
  ];

  sources = [
    (source "v4l2_input" "Facecam" {
      settings = {
        device_id = "/dev/video0";
        input = 0;
        pixelformat = 1196444237;
        resolution = 3435973837400;
        Brightness = 120;
        Contrast = 90;
        Saturation = 135;
        Gamma = 175;
        Gain = 0;
        Sharpness = 200;
        "Backlight Compensation" = 1;
        "White Balance, Automatic" = true;
        "White Balance Temperature" = 5000;
        "Auto Exposure" = 3;
        "Exposure Time, Absolute" = 165;
        "Focus, Absolute" = 0;
        "Focus, Automatic Continuous" = true;
      };
    })

    # /dev/videoN not by-id: v4l2 only auto-reconnects on an exact udev path match
    (source "v4l2_input" "Handcam" {
      settings = {
        device_id = "/dev/video2";
        input = 0;
        pixelformat = 1196444237;
        resolution = 5497558139600;
      };
      filters = [
        (source "shader_filter" "Fisheye" {
          settings = {
            from_file = true;
            shader_file_name = "${pkgs.obs-studio-plugins.obs-shaderfilter}/share/obs/obs-plugins/obs-shaderfilter/examples/fisheye.shader";
            power = -0.18;
          };
        })
      ];
    })

    # no RestoreToken: the portal swaps it each session, so a pinned one is always stale
    (source "pipewire-screen-capture-source" "DP-2" {
      settings.ShowCursor = true;
    })

    (source "browser_source" "Chat" {
      settings = {
        url = "https://www.giambaj.it/twitch/jchat/v2/?channel=luvvlyjude&size=2&font=0&animate=true&fade=30&hide_commands=true";
        width = 750;
      };
    })

    (source "text_ft2_source_v2" "brb" {
      settings.text = "brb getting food";
    })

    # mixers are track bitmasks, track names are in basic.ini [AdvOut]
    (source "pipewire_audio_input_capture" "Mic" {
      settings = {
        TargetName = "alsa_input.usb-Kingston_HyperX_Quadcast_4110-00.analog-stereo";
        TargetId = 0;
      };
      mixers = 203;
      filters = [
        (source "noise_suppress_filter_v2" "Noise Suppression" {
          enabled = false;
        })
        (source "basic_eq_filter" "3-Band Equalizer" {
          settings = {
            low = -2.0;
            mid = -1.5;
            high = 1.0;
          };
        })
        (source "expander_filter" "Expander" {
          settings = {
            threshold = -30.0;
            release_time = 75;
            output_gain = 13.5;
          };
        })
        (source "compressor_filter" "Compressor" {
          settings = {
            ratio = 3.0;
            threshold = -45.0;
            attack_time = 5;
            release_time = 100;
            output_gain = 15.0;
          };
        })
      ];
    })

    (appAudio "Minecraft" "java" 199 1.0)
    (appAudio "Discord" "WEBRTC VoiceEngine" 211 0.392)
    (appAudio "Spotify" "spotify" 225 0.564)
    (appAudio "Zen" "zen-bin" 199 0.237)

    # items are listed bottom to top
    (source "scene" "Main" {
      mixers = 0;
      settings.items = [
        (item "Audio" { })
        (item "DP-2" {
          bounds_type = 1; # stretch
          bounds = {
            x = 1920.0;
            y = 1080.0;
          };
        })
        (item "Facecam" {
          visible = false;
          pos = {
            x = 0.0;
            y = 437.0;
          };
          scale = {
            x = 0.5825;
            y = 0.5833;
          };
        })
        (item "Handcam" {
          rot = 180.0;
          crop_top = 134;
          crop_bottom = 84;
          pos = {
            x = 466.0;
            y = 970.0;
          };
          scale = {
            x = 0.3641;
            y = 0.3645;
          };
        })
        (item "Chat" {
          pos = {
            x = 1346.0;
            y = 621.0;
          };
          scale = {
            x = 0.7653;
            y = 0.765;
          };
        })
        (item "brb" {
          visible = false;
          pos = {
            x = 180.0;
            y = 246.0;
          };
          scale = {
            x = 0.8025;
            y = 0.8025;
          };
        })
      ];
    })

    (source "scene" "Audio" {
      mixers = 0;
      settings.items = map (name: item name { }) [
        "Zen"
        "Spotify"
        "Discord"
        "Mic"
        "Minecraft"
      ];
    })
  ];
}
