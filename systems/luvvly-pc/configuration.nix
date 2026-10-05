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
            extraArgs = [
              "--microsoft"
              "--firmware-builtin"
            ];
          };
          autoGenerateKeys = true;
        };
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # initrd's local-fs.target stays active past switch-root, so bootctl checks
  # /boot before it's mounted. Remove once nixpkgs fixes it.
  systemd.services.systemd-boot-random-seed.unitConfig.RequiresMountsFor = "/boot";
}
