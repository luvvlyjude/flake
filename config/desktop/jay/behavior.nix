{
  jayLib,
  lib,
  pkgs,
  ...
}:

let
  inherit (jayLib)
    createMark
    exec
    moveToOutput
    multi
    showWorkspace
    ;
in
{
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
    (multi [
      (exec (lib.getExe pkgs.jay-tray-power))
      (moveToOutput { output.name = "left"; })
    ])
    (exec { shell = "sleep 0.25; discord"; })
    (exec { shell = "sleep 5; spotify"; })
    (showWorkspace "0")
    (createMark "right-monitor")
    (showWorkspace "1")
    (createMark "left-monitor")
  ];

  drm-devices = [
    {
      match.syspath = "/sys/devices/pci0000:00/0000:00:03.1/0000:09:00.0";
      direct-scanout = true; # client -> monitor, inactive while compositing; whenever a software cursor is visible
    }
  ];
}
