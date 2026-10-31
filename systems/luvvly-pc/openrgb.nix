{ lib, pkgs, ... }:
let
  # TODO: flake-wide theme colors (also in ../../configs/nixos/core/hardware/openrazer.nix)
  color = "800055";

  # see `openrgb --list-detailed`
  lights = {
    "0" = "--mode Static"; # "ENE DRAM" openrgb device 0
    "1" = "--mode Static"; # "ENE DRAM" openrgb device 1
    "RTX 2070" = "--mode Direct";
    "X570" = "--mode Static";
    "Corsair" = "--zone 0 --size 32 --mode Static"; # 4 fans x 8 LEDs
    "Keychron" = "--mode 'Solid Color'";
  };

  # `openrgb-colors [hex]` sets every light to hex, or to color without one
  setColors = pkgs.writeShellApplication {
    name = "openrgb-colors";
    runtimeInputs = [ pkgs.openrgb ];
    # devices take a sec to show up so we retry each one, then skip it so a missing one can't block the rest
    text = ''
      color=''${1:-${color}}

      light() {
        device=$1
        shift
        for _ in {1..10}; do
          openrgb --nodetect --device "$device" "$@" --color "$color" && return
          sleep 1
        done
      }

      ${lib.concatLines (
        lib.mapAttrsToList (device: flags: "light ${lib.escapeShellArg device} ${flags}") lights
      )}
    '';
  };
in
{
  services.hardware.openrgb.enable = true;

  # load early: stage 2 skips modules-load on this machine (systemd#3436)
  boot.initrd.kernelModules = [
    "i2c-dev"
    "i2c-piix4"
  ];

  systemd.services.openrgb-colors = {
    after = [ "openrgb.service" ];
    requires = [ "openrgb.service" ];
    wantedBy = [ "openrgb.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe setColors;
    };
  };

  # lights off while idle.target is up, back on when it stops (see configs/home/services/swayidle)
  systemd.user.services.openrgb-idle = {
    wantedBy = [ "idle.target" ];
    partOf = [ "idle.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${lib.getExe setColors} 000000";
      ExecStop = lib.getExe setColors;
    };
  };
}
