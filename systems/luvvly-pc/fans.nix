{
  lib,
  pkgs,
  ...
}:
let
  # minPwm is the BIOS idle speed; setting min and max skips fan2go's sweep of each fan
  fan = id: rpmChannel: curve: {
    inherit id curve;
    hwmon = {
      platform = "it8688";
      inherit rpmChannel;
    };
    neverStop = true;
    minPwm = 70;
    startPwm = 70;
    maxPwm = 255;
  };

  settings = {
    # fan4 is the PCH fan, left to the BIOS; fan5 is an empty header
    fans = [
      (fan "cpu" 1 "cpu")
      (fan "front" 2 "case") # middle front intake
      (fan "rear" 3 "case") # back and top fans, on a splitter
    ];

    sensors = [
      {
        id = "cpu";
        hwmon = {
          platform = "k10temp";
          index = 1; # Tctl
        };
      }
      {
        id = "gpu";
        # needs NVML, which fan2go only builds with under cudaSupport
        nvidia = {
          device = "nvidia-10DE1E84-0A00";
          index = 1;
        };
      }
    ];

    # 0% is minPwm, 100% is maxPwm
    curves = [
      {
        id = "cpu";
        linear = {
          sensor = "cpu";
          steps = [
            { "50" = "0%"; }
            { "70" = "40%"; }
            { "85" = "100%"; }
          ];
        };
      }
      {
        id = "gpu";
        linear = {
          sensor = "gpu";
          steps = [
            { "50" = "0%"; }
            { "65" = "40%"; }
            { "80" = "100%"; }
          ];
        };
      }
      {
        id = "case";
        function = {
          type = "maximum";
          curves = [
            "cpu"
            "gpu"
          ];
        };
      }
    ];
  };
in
{
  # no NixOS module for fan2go; on exit it hands the fans back to the BIOS
  systemd.services.fan2go = {
    description = "fan2go fan control";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.fan2go} -c ${
        (pkgs.formats.yaml { }).generate "fan2go.yaml" settings
      }";
      Restart = "always";
      StateDirectory = "fan2go";
    };
  };
}
