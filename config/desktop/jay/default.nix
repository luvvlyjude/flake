{ inputs, pkgs, ... }:

{
  imports = [ inputs.jay.nixosModules.default ];

  programs.jay = {
    enable = true;

    # jay bin gets CAP_SYS_NICE
    # elevated scheduler and high-priority vulkan queues
    # better performance under load
    # default is true but here for clarity
    realtime-scheduling = true;

    xwayland.enable = true;

    extraPackages = with pkgs; [
      mako
      wl-tray-bridge
    ];
  };

  home-manager.sharedModules = [
    {
      imports = [ inputs.jay.homeManagerModules.default ];

      wayland.windowManager.jay = {
        enable = true;

        # a backup of my config from right before i switched to nixos is available at ./config.toml
        # these settings r based on that
        settings = {
          # Vulkan to make gpu-screen-recorder-ui work
          # DP-2 requires vrr always and cursor-hz 60 for cursor to be smooth on some apps
          # OpenGl for cursor tearing, possibly better input delay for cursor
          # no laggy cursor on any apps, breaks gpu-screen-recorder-ui
          gfx-api = "Vulkan";
          use-hardware-cursor = false;

          unstable-mouse-follows-focus = true;

          idle.minutes = 0;

          repeat-rate = {
            rate = 50;
            delay = 200;
          };

          # window-management-key = "Super_L";

          focus-follows-mouse = false;

          middle-click-paste = false;

          workspace-display-order = "sorted";

          fallback-output-mode = "focus";

          # on-startup = [
          # 	{ type = "exec"; exec = "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"; };
          # 	{ type = "exec"; exec = "gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'"; };
          # ];

          on-graphics-initialized = [
            {
              type = "show-workspace";
              name = "mrrp :3";
              output.name = "right";
            }
            {
              type = "show-workspace";
              name = "meow <3";
              output.name = "left";
            }
            # {
            #   type = "push-mode";
            #   name = "default";
            # }
            {
              type = "exec";
              exec = "discord";
            }
            {
              type = "exec";
              exec = "/home/jude/delayed-spotify.sh";
            }
          ];

          actions = {
            switch-monitor = "$switch-to-mrrp";
            switch-to-meow = [
              {
                type = "show-workspace";
                name = "meow <3";
                output.name = "left";
              }
              {
                type = "define-action";
                name = "switch-monitor";
                action = "$switch-to-mrrp";
              }
            ];
            switch-to-mrrp = [
              {
                type = "show-workspace";
                name = "mrrp :3";
                output.name = "right";
              }
              {
                type = "define-action";
                name = "switch-monitor";
                action = "$switch-to-meow";
              }
            ];
          };

          keymap = ''
            xkb_keymap {
                xkb_keycodes { include "evdev+aliases(qwerty)"                };
                xkb_types    { include "complete+numpad(mac)"                 };
                xkb_compat   { include "complete"                             };
                xkb_symbols  { include "pc+us+inet(evdev)+fkeys(basic_13-24)" };
            };
          '';

          env = {
            GDK_BACKEND = "wayland";
            QT_QPA_PLATFORM = "wayland";
            SDL_VIDEODRIVER = "wayland";
            CLUTTER_BACKEND = "wayland";
            ELECTRON_OZONE_PLATFORM_HINT = "wayland";
            XDG_SESSION_TYPE = "wayland";
            MOZ_ENABLE_WAYLAND = "1";

            GDM_BACKEND = "nvidia-drm";
            __GLX_VENDOR_LIBRARY_NAME = "nvidia";
            LIBVA_DRIVER_NAME = "nvidia";

            RANGER_LOAD_DEFAULT_RC = "FALSE";
          };

          status = {
            format = "i3bar";
            exec = [
              "i3status-rs"
              "config-jay"
            ];
            i3bar-separator = "";
          };

          outputs = [
            {
              name = "left";
              match.connector = "DP-2";
              mode = {
                width = 3840;
                height = 2160;
                refresh-rate = 59.997;
              };
              vrr = {
                mode = "always";
                cursor-hz = "none";
              };
              tearing.mode = "variant1"; # enabled when one or more applications r displayed fullscreen
              scale = 2.0;
              x = 0;
            }
            {
              name = "right";
              match.connector = "HDMI-A-1";
              mode = {
                width = 1680;
                height = 1050;
                refresh-rate = 59.954;
              };
              tearing.mode = "variant1"; # ""
              x = 1920;
            }
          ];

          drm-devices = [
            {
              match.syspath = "/sys/devices/pci0000:00/0000:00:03.1/0000:09:00.0";
              direct-scanout = true; # client -> monitor, inactive while compositing; whenever a software cursor is visible
            }
          ];

          cursor-size = 32;

          theme = {
            font = "monospace 8";
            border-width = 1;
            border-color = "#350030";
            bar-separator-width = 1;
            separator-color = "#350030";
            bg-color = "#000000";
            focused-title-bg-color = "#350030";
            focused-title-text-color = "#EEEEEE";
            unfocused-title-bg-color = "#000000";
            unfocused-title-text-color = "#999999";
            focused-inactive-title-bg-color = "#250015";
            focused-inactive-title-text-color = "#999999";
          };

          inputs = [
            {
              match.is-pointer = true;
              accel-profile = "flat";
              accel-speed = -0.9375;
              natural-scrolling = false;
            }
            {
              match.name = "ydotoold virtual device";
              # accel-speed = 0.0;
              accel-speed = -0.5;
            }
            {
              match.is-keyboard = true;
            }
          ];

          windows = [
            {
              name = "2nd-monitor";
              match.any = [
                { app-id = "discord"; }
                { app-id = "spotify"; }
                { x-class = "Spotify"; }
                { app-id = "com.obsproject.Studio"; }
              ];
              action = [
                {
                  type = "move-to-workspace";
                  name = "mrrp :3";
                }
                {
                  type = "simple";
                  cmd = "show-single";
                }
              ];
              auto-focus = false;
            }
            {
              name = "waywall";
              match.app-id = "waywall";
              action = {
                type = "move-to-workspace";
                name = "meow <3";
              };
              auto-focus = false;
            }
            {
              name = "swappy";
              match.app-id = "swappy";
              action = [
                {
                  type = "move-to-workspace";
                  name = "meow <3";
                }
                {
                  type = "show-workspace";
                  name = "meow <3";
                }
                "enter-fullscreen"
              ];
            }
          ];

          clients = [
            {
              match.all = [ ];
              capabilities = "all";
            }
          ];

          # [modes."default".shortcuts]
          shortcuts = {
            F24 = {
              type = "push-mode";
              name = "disabled";
            };
            F23 = "none";

            logo-q = {
              type = "exec";
              exec = "footclient";
            };
            logo-r = {
              type = "exec";
              exec = [ "fuzzel" ];
            };
            logo-shift-s = {
              type = "exec";
              exec = {
                prog = "bash";
                args = [
                  "-lc"
                  "grim -g \"$(slurp -d)\" - | swappy -f - -o - | wl-copy"
                ];
                privileged = true;
              };
            };

            logo-alt-c = "close";
            logo-alt-r = "reload-config-toml";
            logo-alt-m = "quit";

            logo-d = "split-horizontal";
            logo-s = "toggle-mono";
            logo-f = "toggle-fullscreen";
            logo-v = "toggle-floating";

            logo-semicolon = "$switch-monitor";
            # logo-return             =;
            # logo-shift-return       =;
            logo-h = "focus-left";
            logo-shift-h = "move-left";
            # logo-j                  = "focus-next";
            # logo-shift-j            =;
            # logo-k                  = "focus-prev";
            # logo-shift-k            =;
            logo-l = "focus-right";
            logo-shift-l = "move-right";

            logo-1 = {
              type = "show-workspace";
              name = "meow <3";
              output.name = "left";
            };
            logo-2 = {
              type = "show-workspace";
              name = "2";
              output.name = "left";
            };
            logo-3 = {
              type = "show-workspace";
              name = "3";
              output.name = "left";
            };
            logo-4 = {
              type = "show-workspace";
              name = "4";
              output.name = "left";
            };
            logo-5 = {
              type = "show-workspace";
              name = "5";
              output.name = "left";
            };
            logo-6 = {
              type = "show-workspace";
              name = "6";
              output.name = "right";
            };
            logo-7 = {
              type = "show-workspace";
              name = "7";
              output.name = "right";
            };
            logo-8 = {
              type = "show-workspace";
              name = "8";
              output.name = "right";
            };
            logo-9 = {
              type = "show-workspace";
              name = "9";
              output.name = "right";
            };
            logo-0 = {
              type = "show-workspace";
              name = "mrrp :3";
              output.name = "right";
            };

            logo-shift-1 = [
              {
                type = "move-to-workspace";
                name = "meow <3";
              }
              {
                type = "show-workspace";
                name = "meow <3";
              }
              {
                type = "move-to-output";
                output.name = "left";
              }
              {
                type = "show-workspace";
                name = "meow <3";
              }
            ];
            logo-shift-2 = [
              {
                type = "move-to-workspace";
                name = "2";
              }
              {
                type = "show-workspace";
                name = "2";
              }
              {
                type = "move-to-output";
                output.name = "left";
              }
              {
                type = "show-workspace";
                name = "2";
              }
            ];
            logo-shift-3 = [
              {
                type = "move-to-workspace";
                name = "3";
              }
              {
                type = "show-workspace";
                name = "3";
              }
              {
                type = "move-to-output";
                output.name = "left";
              }
              {
                type = "show-workspace";
                name = "3";
              }
            ];
            logo-shift-4 = [
              {
                type = "move-to-workspace";
                name = "4";
              }
              {
                type = "show-workspace";
                name = "4";
              }
              {
                type = "move-to-output";
                output.name = "left";
              }
              {
                type = "show-workspace";
                name = "4";
              }
            ];
            logo-shift-5 = [
              {
                type = "move-to-workspace";
                name = "5";
              }
              {
                type = "show-workspace";
                name = "5";
              }
              {
                type = "move-to-output";
                output.name = "left";
              }
              {
                type = "show-workspace";
                name = "5";
              }
            ];
            logo-shift-6 = [
              {
                type = "move-to-workspace";
                name = "6";
              }
              {
                type = "show-workspace";
                name = "6";
              }
              {
                type = "move-to-output";
                output.name = "right";
              }
              {
                type = "show-workspace";
                name = "6";
              }
            ];
            logo-shift-7 = [
              {
                type = "move-to-workspace";
                name = "7";
              }
              {
                type = "show-workspace";
                name = "7";
              }
              {
                type = "move-to-output";
                output.name = "right";
              }
              {
                type = "show-workspace";
                name = "7";
              }
            ];
            logo-shift-8 = [
              {
                type = "move-to-workspace";
                name = "8";
              }
              {
                type = "show-workspace";
                name = "8";
              }
              {
                type = "move-to-output";
                output.name = "right";
              }
              {
                type = "show-workspace";
                name = "8";
              }
            ];
            logo-shift-9 = [
              {
                type = "move-to-workspace";
                name = "9";
              }
              {
                type = "show-workspace";
                name = "9";
              }
              {
                type = "move-to-output";
                output.name = "right";
              }
              {
                type = "show-workspace";
                name = "9";
              }
            ];
            logo-shift-0 = [
              {
                type = "move-to-workspace";
                name = "mrrp :3";
              }
              {
                type = "show-workspace";
                name = "mrrp :3";
              }
              {
                type = "move-to-output";
                output.name = "right";
              }
              {
                type = "show-workspace";
                name = "mrrp :3";
              }
            ];

            ctrl-alt-F1 = {
              type = "switch-to-vt";
              num = 1;
            };
            ctrl-alt-F2 = {
              type = "switch-to-vt";
              num = 2;
            };
            ctrl-alt-F3 = {
              type = "switch-to-vt";
              num = 3;
            };
            ctrl-alt-F4 = {
              type = "switch-to-vt";
              num = 4;
            };
            ctrl-alt-F5 = {
              type = "switch-to-vt";
              num = 5;
            };
            ctrl-alt-F6 = {
              type = "switch-to-vt";
              num = 6;
            };
            ctrl-alt-F7 = {
              type = "switch-to-vt";
              num = 7;
            };
            ctrl-alt-F8 = {
              type = "switch-to-vt";
              num = 8;
            };
            ctrl-alt-F9 = {
              type = "switch-to-vt";
              num = 9;
            };

            XF86AudioPlay = {
              type = "exec";
              exec = {
                prog = "bash";
                args = [
                  "-c"
                  "playerctl -i firefox play-pause"
                ];
              };
            };
            XF86AudioNext = {
              type = "exec";
              exec = {
                prog = "bash";
                args = [
                  "-c"
                  "playerctl -i firefox next"
                ];
              };
            };
            XF86AudioPrev = {
              type = "exec";
              exec = {
                prog = "bash";
                args = [
                  "-c"
                  "playerctl -i firefox previous"
                ];
              };
            };
          };

          modes."disabled".shortcuts = {
            F23 = "pop-mode";
            F24 = "none";

            logo-q = "none";
            logo-r = "none";
            logo-shift-s = "none";

            logo-alt-c = "none";
            logo-alt-r = "none";
            logo-alt-m = "none";

            logo-s = "none";
            logo-f = "none";
            logo-v = "none";

            logo-semicolon = "none";
            # logo-return       =;
            # logo-shift-return =;
            logo-h = "none";
            logo-shift-h = "none";
            # logo-j            = "focus-next";
            # logo-shift-j      =;
            # logo-k            = "focus-prev";
            # logo-shift-k      =;
            logo-l = "none";
            logo-shift-l = "none";

            logo-1 = "none";
            logo-2 = "none";
            logo-3 = "none";
            logo-4 = "none";
            logo-5 = "none";
            logo-6 = "none";
            logo-7 = "none";
            logo-8 = "none";
            logo-9 = "none";
            logo-0 = "none";

            logo-shift-1 = "none";
            logo-shift-2 = "none";
            logo-shift-3 = "none";
            logo-shift-4 = "none";
            logo-shift-5 = "none";
            logo-shift-6 = "none";
            logo-shift-7 = "none";
            logo-shift-8 = "none";
            logo-shift-9 = "none";
            logo-shift-0 = "none";
          };
        };
      };
    }
  ];
}
