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

  # initrd's local-fs.target stays active past switch-root, so bootctl checks
  # /boot before it's mounted. Remove once nixpkgs fixes it.
  systemd.services.systemd-boot-random-seed.unitConfig.RequiresMountsFor = "/boot";
}
