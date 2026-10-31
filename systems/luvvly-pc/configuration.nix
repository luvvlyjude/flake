{ pkgs, ... }:

{
  boot = {
    loader = {
      # systemd-boot.enable = true;
      limine = {
        enable = true;
        secureBoot = {
          enable = true;
          autoEnrollKeys = {
            enable = true;
            # firmware-builtin adds malformed Gigabyte db certs the kernel rejects at boot
            extraArgs = [ "--microsoft" ];
          };
          autoGenerateKeys = true;
        };
        additionalFiles."efi/memtest86/memtest86.efi" = "${pkgs.memtest86-efi}/BOOTX64.efi";
        extraEntries = ''
          /memtest86
            protocol: efi
            path: boot():///efi/memtest86/memtest86.efi
        '';
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # wait for the ESP: stage 2 doesn't re-run local-fs.target on this machine (systemd#3436)
  systemd.services.systemd-boot-random-seed.unitConfig.RequiresMountsFor = "/boot";

  services.smartd = {
    enable = true;
    # 7s ERC: bcachefs rebuilds from parity instead of stalling on a bad sector
    # APM 254: stops the HGSTs parking their heads every few seconds
    # standby off: never spin down, spin-ups wear more than spinning
    # 197+/198+: warn when bad-sector counts grow, not on every start
    defaults.autodetected = "-a -C 197+ -U 198+ -l scterc,70,70 -e apm,254 -e standby,off";
    notifications.systembus-notify.enable = true;
  };
}
