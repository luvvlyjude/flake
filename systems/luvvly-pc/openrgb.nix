{
  lib,
  pkgs,
  username,
  ...
}:
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

  # `rgb-colors <hex>` sets every light to hex
  setColors = pkgs.writeShellApplication {
    name = "rgb-colors";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.nvme-cli
      pkgs.openrgb
    ];
    # devices take a sec to show up so we retry each one, then skip it so a missing one can't block the rest
    text = ''
      # only accept hex since its sent straight to the drive
      if [[ ! ''${1:-} =~ ^[0-9a-fA-F]{6}$ ]]; then
        echo "usage: rgb-colors <hex>" >&2
        exit 1
      fi
      color=$1

      # 990 PRO LED via Samsung's vendor command: on, static, color as BGR
      red=''${color:0:2}
      green=''${color:2:2}
      blue=''${color:4:2}
      payload=$(mktemp)
      printf '%b' "\x02\0\0\0" "\x01\0\0\0" "\x$blue\x$green\x$red" > "$payload"
      truncate -s 512 "$payload"
      nvme security-send /dev/disk/by-id/nvme-Samsung_SSD_990_PRO_with_Heatsink_1TB_S73JNJ0Y100151D \
        --secp=0xfe --spsp=0x33 --tl=512 --file="$payload" || true
      rm "$payload"

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

  systemd.services.rgb-colors = {
    after = [ "openrgb.service" ];
    requires = [ "openrgb.service" ];
    wantedBy = [ "openrgb.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe setColors} ${color}";
    };
  };

  # lights off while idle.target is up, back on when it stops (see configs/home/services/swayidle)
  systemd.user.services.rgb-idle = {
    wantedBy = [ "idle.target" ];
    partOf = [ "idle.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/run/wrappers/bin/sudo -n ${lib.getExe setColors} 000000";
      ExecStopPost = "/run/wrappers/bin/sudo -n ${lib.getExe setColors} ${color}";
    };
  };

  # the 990 PRO LED needs root
  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          command = lib.getExe setColors;
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
