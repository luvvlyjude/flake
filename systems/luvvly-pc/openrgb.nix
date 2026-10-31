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
    path = [ pkgs.openrgb ];
    # devices take a sec to show up so we retry repeatedly with a script
    script = ''
      light() {
        device=$1
        shift
        until openrgb --nodetect --device "$device" "$@" --color ${color}; do
          sleep 1
        done
      }

      ${lib.concatLines (
        lib.mapAttrsToList (device: flags: "light ${lib.escapeShellArg device} ${flags}") lights
      )}
    '';
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = 60;
    };
  };
}
