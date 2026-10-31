{
  lib,
  pkgs,
  username,
  ...
}:
let
  # TODO: flake-wide theme colors (also in ../../../../systems/luvvly-pc/openrgb.nix)
  color = "800055";
  logoBrightness = 10;
  sleepSeconds = 300;

  # custom script to apply our settings because openrazer has no options
  applySettings =
    pkgs.writers.writePython3Bin "openrazer-settings"
      {
        libraries = [ pkgs.python3Packages.openrazer ];
      }
      ''
        from openrazer.client import DeviceManager

        red, green, blue = bytes.fromhex("${color}")

        for device in DeviceManager().devices:
            if device.has("lighting_logo_static"):
                device.fx.misc.logo.static(red, green, blue)
                device.fx.misc.logo.brightness = ${toString logoBrightness}
            if device.has("set_idle_time"):
                device.set_idle_time(${toString sleepSeconds})
      '';
in
{
  # for the mouse, which forgets OpenRGB's colors when it sleeps
  hardware.openrazer = {
    enable = true;
    users = [ username ];
  };

  # load early: stage 2 skips modules-load on this machine (systemd#3436)
  boot.initrd.kernelModules = [ "razermouse" ];

  systemd.user.services.openrazer-settings = {
    after = [ "openrazer-daemon.service" ];
    requires = [ "openrazer-daemon.service" ];
    wantedBy = [ "openrazer-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe applySettings;
    };
  };
}
